// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AppKit
import CoreGraphics
import Darwin
import Foundation

private enum SourceState: String {
  case permissionUnavailable = "PERMISSION_UNAVAILABLE"
  case invalidConfiguration = "INVALID_CONFIGURATION"
  case displayUnavailable = "DISPLAY_UNAVAILABLE"
  case guardInvalid = "GUARD_INVALID"
  case capturing = "CAPTURING"
  case captureFailed = "CAPTURE_FAILED"
  case disconnected = "DISCONNECTED"
  case stopping = "STOPPING"
}

private enum CaptureApplicationError: LocalizedError {
  case wrongBundleIdentity(String?)
  case permissionDenied
  case permissionChangedRelaunchRequired
  case outputFailed(String)
  case captureFailed(String)
  case displayInvalid(String)

  var errorDescription: String? {
    switch self {
    case .wrongBundleIdentity(let actual):
      return "run the packaged PushwigCaptureHelper.app; bundle identity was \(actual ?? "absent")"
    case .permissionDenied:
      return
        "Screen Recording permission is unavailable; enable Pushwig Capture Helper in System Settings > Privacy & Security > Screen & System Audio Recording, then relaunch this same app build"
    case .permissionChangedRelaunchRequired:
      return
        "Screen Recording permission was granted; relaunch this same exact Pushwig Capture Helper app build"
    case .outputFailed(let message):
      return "external raster output failed: \(message)"
    case .captureFailed(let message):
      return "display crop capture failed: \(message)"
    case .displayInvalid(let message):
      return "selected display is no longer valid: \(message)"
    }
  }
}

@MainActor
private final class CaptureApplication {
  private let configuration: CaptureConfiguration
  private let capture: DisplayCropCapture
  private let outputCoordinator: CaptureOutputCoordinator
  private var currentState: SourceState?
  private var currentGuardDecision: SourceValidityDecision
  private var stopRequested = false
  private var finished = false
  private var guardPollCount: UInt64 = 0
  private var displayRevalidationCount: UInt64 = 0
  private var permissionRevalidationCount: UInt64 = 0

  init(
    configuration: CaptureConfiguration,
    capture: DisplayCropCapture,
    outputCoordinator: CaptureOutputCoordinator,
    initialGuardDecision: SourceValidityDecision
  ) {
    self.configuration = configuration
    self.capture = capture
    self.outputCoordinator = outputCoordinator
    currentGuardDecision = initialGuardDecision
  }

  func requestStop() {
    stopRequested = true
  }

  func run() async throws {
    do {
      try await capture.start()
      transition(
        to: currentGuardDecision.isValid ? .capturing : .guardInvalid,
        detail: "guard=\(currentGuardDecision.reason)"
      )

      while !stopRequested {
        if let failure = outputCoordinator.failureDescription() {
          transition(to: .disconnected, detail: bounded(failure))
          throw CaptureApplicationError.outputFailed(failure)
        }
        if let failure = capture.captureFailure() {
          transition(to: .captureFailed, detail: bounded(failure))
          throw CaptureApplicationError.captureFailed(failure)
        }

        let guardDecision = SourceValidityGate.evaluate(
          requiredBundleIdentifier: configuration.requiredFrontmostBundleIdentifier!,
          snapshot: SourceValidityGate.observe()
        )
        if guardDecision != currentGuardDecision {
          currentGuardDecision = guardDecision
          capture.updateGuard(guardDecision)
          transition(
            to: guardDecision.isValid ? .capturing : .guardInvalid,
            detail: "guard=\(guardDecision.reason)"
          )
        }

        guardPollCount += 1
        if guardPollCount % CaptureConfiguration.displayRevalidationPollInterval == 0 {
          try revalidateDisplay()
        }
        if guardPollCount % CaptureConfiguration.permissionRevalidationPollInterval == 0 {
          permissionRevalidationCount += 1
          if !CGPreflightScreenCaptureAccess() {
            transition(to: .permissionUnavailable, detail: "runtime permission unavailable")
            throw CaptureApplicationError.permissionDenied
          }
        }
        try await Task.sleep(nanoseconds: CaptureConfiguration.guardPollNanoseconds)
      }
      await finish()
    } catch {
      await finish()
      throw error
    }
  }

  private func revalidateDisplay() throws {
    let facts: [DisplayFact]
    do {
      facts = try DisplayDiscovery.currentActiveFacts()
    } catch {
      transition(to: .displayUnavailable, detail: "inventory unavailable")
      throw CaptureApplicationError.displayInvalid("inventory unavailable")
    }

    do {
      try DisplayDiscovery.validateCurrent(
        facts: facts,
        expected: capture.metadata.displayFact
      )
      displayRevalidationCount += 1
    } catch {
      transition(to: .displayUnavailable, detail: bounded(error.localizedDescription))
      throw CaptureApplicationError.displayInvalid(error.localizedDescription)
    }
  }

  private func finish() async {
    guard !finished else { return }
    finished = true
    transition(to: .stopping, detail: "normal authority revocation")
    await capture.stop()
    print(
      "CONTROL_LOOP guard_polls=\(guardPollCount) "
        + "display_revalidations=\(displayRevalidationCount) "
        + "permission_revalidations=\(permissionRevalidationCount)"
    )
    print(outputCoordinator.shutdown())
  }

  private func transition(to state: SourceState, detail: String) {
    guard currentState != state else { return }
    currentState = state
    print("STATE value=\(state.rawValue) \(detail)")
  }

  private func bounded(_ text: String) -> String {
    String(text.replacingOccurrences(of: "\n", with: " ").prefix(240))
  }
}

@MainActor
private final class SignalController {
  private var sources: [DispatchSourceSignal] = []

  init(handler: @escaping () -> Void) {
    for signalNumber in [SIGINT, SIGTERM] {
      signal(signalNumber, SIG_IGN)
      let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
      source.setEventHandler(handler: handler)
      source.resume()
      sources.append(source)
    }
  }
}

@MainActor
private func runMain() async -> Int32 {
  let configuration: CaptureConfiguration
  do {
    configuration = try CaptureConfiguration.parse(
      arguments: Array(CommandLine.arguments.dropFirst())
    )
  } catch CaptureConfigurationError.helpRequested {
    print(CaptureConfiguration.usage)
    return 0
  } catch {
    fputs(
      "STATE value=\(SourceState.invalidConfiguration.rawValue)\n"
        + "error: \(error.localizedDescription)\n\(CaptureConfiguration.usage)\n",
      stderr
    )
    return 64
  }

  let actualBundleIdentifier = Bundle.main.bundleIdentifier
  guard actualBundleIdentifier == CaptureConfiguration.expectedBundleIdentifier else {
    fputs(
      "error: \(CaptureApplicationError.wrongBundleIdentity(actualBundleIdentifier).localizedDescription)\n",
      stderr
    )
    return 78
  }
  print("IDENTITY bundle_id=\(actualBundleIdentifier!)")

  switch ensureScreenRecordingPermission() {
  case .available:
    break
  case .denied:
    fputs(
      "STATE value=\(SourceState.permissionUnavailable.rawValue)\n"
        + "error: \(CaptureApplicationError.permissionDenied.localizedDescription)\n",
      stderr
    )
    return 77
  case .grantedNeedsRelaunch:
    fputs(
      "STATE value=\(SourceState.permissionUnavailable.rawValue)\n"
        + "error: \(CaptureApplicationError.permissionChangedRelaunchRequired.localizedDescription)\n",
      stderr
    )
    return 77
  }

  let candidates: [DisplayCandidate]
  do {
    candidates = try await DisplayDiscovery.currentCandidates()
  } catch {
    fputs("error: display inventory failed: \(error.localizedDescription)\n", stderr)
    return 69
  }

  if configuration.listDisplays {
    DisplayDiscovery.printInventory(candidates: candidates)
    return 0
  }

  guard let displayID = configuration.displayID,
    let expectedWidth = configuration.expectedDisplayWidth,
    let expectedHeight = configuration.expectedDisplayHeight,
    let crop = configuration.normalizedCrop,
    let destination = configuration.destination,
    let port = configuration.port,
    let tokenFile = configuration.tokenFile,
    let requiredBundleID = configuration.requiredFrontmostBundleIdentifier
  else {
    fputs("error: internal incomplete capture configuration\n", stderr)
    return 64
  }

  let selected: DisplayCandidate
  do {
    selected = try DisplayDiscovery.select(
      candidates: candidates,
      displayID: displayID,
      expectedWidth: expectedWidth,
      expectedHeight: expectedHeight
    )
  } catch {
    fputs(
      "STATE value=\(SourceState.displayUnavailable.rawValue)\n"
        + "error: \(error.localizedDescription)\n",
      stderr
    )
    return 69
  }

  let cropStart = DispatchTime.now().uptimeNanoseconds
  let requestedSourceRect: CGRect
  do {
    requestedSourceRect = try AspectMapping.requestedSourceRect(
      displayWidth: selected.fact.width,
      displayHeight: selected.fact.height,
      crop: crop
    )
  } catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    return 64
  }
  let cropEnd = DispatchTime.now().uptimeNanoseconds

  let aspectStart = cropEnd
  let mapping: AspectMapping
  do {
    mapping = try AspectMapping.centeredCover(
      requestedSourceRect: requestedSourceRect,
      displayWidth: selected.fact.width,
      displayHeight: selected.fact.height,
      destination: destination
    )
  } catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    return 64
  }
  let aspectEnd = DispatchTime.now().uptimeNanoseconds

  print(
    "SELECTION display_id=\(selected.fact.displayID) width=\(selected.fact.width) "
      + "height=\(selected.fact.height) unit=screen-points main=\(selected.fact.isMain)"
  )
  print(
    "CROP normalized=\(format(crop)) "
      + "requested_points=\(DisplayDiscovery.format(requestedSourceRect)) "
      + "effective_points=\(mapping.effectiveSourceRect) policy=\(mapping.policy.rawValue)"
  )
  print(
    String(
      format: "ASPECT requested=%.9f effective=%.9f destination=%.9f scale=%.9f "
        + "crop_left=%.3f crop_top=%.3f crop_right=%.3f crop_bottom=%.3f",
      mapping.requestedSourceAspect,
      mapping.effectiveSourceAspect,
      mapping.destinationAspect,
      mapping.uniformScale,
      mapping.croppedLeft,
      mapping.croppedTop,
      mapping.croppedRight,
      mapping.croppedBottom
    )
  )
  print(
    "OUTPUT destination=\(destination.x),\(destination.y),\(destination.width),\(destination.height) "
      + "stride=\(destination.stride) payload_bytes=\(destination.payloadBytes) "
      + "pixel_format=OPAQUE_BGRA8888 row_order=top-to-bottom"
  )
  print("GUARD required_running_and_frontmost_bundle_id=\(requiredBundleID)")

  let initialGuard = SourceValidityGate.evaluate(
    requiredBundleIdentifier: requiredBundleID,
    snapshot: SourceValidityGate.observe()
  )

  do {
    let client = try ExternalRasterProtocolClient(port: port, tokenFile: tokenFile)
    let coordinator = CaptureOutputCoordinator(client: client, destination: destination)
    let capture = try DisplayCropCapture(
      candidate: selected,
      configuration: configuration,
      mapping: mapping,
      generation: 1,
      initialGuardValid: initialGuard.isValid,
      cropCalculationNanoseconds: cropEnd - cropStart,
      aspectCalculationNanoseconds: aspectEnd - aspectStart,
      outputCoordinator: coordinator
    )
    let metadata = capture.metadata
    print(
      "SCK content_rect_points=\(DisplayDiscovery.format(metadata.filterContentRect)) "
        + String(format: "point_pixel_scale=%.6f ", metadata.pointPixelScale)
        + "source_rect_points=\(metadata.mapping.effectiveSourceRect) "
        + "output_pixels=\(destination.width)x\(destination.height) "
        + "preserves_aspect=true scales_to_fit=true cursor=false queue_depth=2 fps=\(metadata.fps)"
    )

    let application = CaptureApplication(
      configuration: configuration,
      capture: capture,
      outputCoordinator: coordinator,
      initialGuardDecision: initialGuard
    )
    let signals = SignalController {
      Task { @MainActor in application.requestStop() }
    }
    _ = signals
    try await application.run()
    return 0
  } catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    return 70
  }
}

private enum PermissionResult {
  case available
  case denied
  case grantedNeedsRelaunch
}

private func ensureScreenRecordingPermission() -> PermissionResult {
  if CGPreflightScreenCaptureAccess() {
    print("PERMISSION preflight=granted attribution=helper-app")
    return .available
  }
  let granted = CGRequestScreenCaptureAccess()
  print(
    "PERMISSION preflight=denied request=\(granted ? "granted" : "denied") attribution=helper-app")
  return granted ? .grantedNeedsRelaunch : .denied
}

private func format(_ crop: NormalizedCrop) -> String {
  String(
    format: "%.6f,%.6f,%.6f,%.6f",
    crop.x,
    crop.y,
    crop.width,
    crop.height
  )
}

_ = NSApplication.shared.setActivationPolicy(.accessory)
Task { @MainActor in exit(await runMain()) }
NSApplication.shared.run()
