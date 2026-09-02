// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AppKit
import CoreGraphics
import Darwin
import Foundation

enum SourceState: String {
  case permissionUnavailable = "PERMISSION_UNAVAILABLE"
  case invalidConfiguration = "INVALID_CONFIGURATION"
  case displayUnavailable = "DISPLAY_UNAVAILABLE"
  case windowUnavailable = "WINDOW_UNAVAILABLE"
  case windowAmbiguous = "WINDOW_AMBIGUOUS"
  case guardInvalid = "GUARD_INVALID"
  case capturing = "CAPTURING"
  case captureFailed = "CAPTURE_FAILED"
  case disconnected = "DISCONNECTED"
  case stopping = "STOPPING"
}

enum CaptureApplicationError: LocalizedError {
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
      return "capture failed: \(message)"
    case .displayInvalid(let message):
      return "selected display is no longer valid: \(message)"
    }
  }
}

@MainActor
private final class DisplayCaptureApplication {
  private let configuration: DisplayModeConfiguration
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
    configuration: DisplayModeConfiguration,
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
          requiredBundleIdentifier: configuration.requiredFrontmostBundleIdentifier,
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
    reportInvalidConfiguration(error)
    return 64
  }

  let profile: VisualProfile?
  if case .profile(let profileConfiguration) = configuration.mode {
    do {
      profile = try VisualProfile.load(from: profileConfiguration.profileFile)
    } catch {
      reportInvalidConfiguration(error)
      return 64
    }
  } else {
    profile = nil
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

  switch configuration.mode {
  case .listDisplays:
    do {
      DisplayDiscovery.printInventory(candidates: try await DisplayDiscovery.currentCandidates())
      return 0
    } catch {
      fputs("error: display inventory failed: \(error.localizedDescription)\n", stderr)
      return 69
    }
  case .listWindows(let ownerBundleIdentifier):
    do {
      let candidates = try await WindowDiscovery.currentCandidates(
        ownerBundleIdentifier: ownerBundleIdentifier
      )
      WindowDiscovery.printInventory(
        candidates: candidates,
        ownerBundleIdentifier: ownerBundleIdentifier
      )
      return 0
    } catch {
      fputs("error: window inventory failed: \(error.localizedDescription)\n", stderr)
      return 69
    }
  case .display(let displayConfiguration):
    return await runDisplayMode(displayConfiguration)
  case .profile(let profileConfiguration):
    guard let profile else {
      reportInvalidConfiguration(
        CaptureConfigurationError.invalid("internal missing visual profile")
      )
      return 64
    }
    return await runProfileMode(profileConfiguration, profile: profile)
  }
}

@MainActor
private func runDisplayMode(_ configuration: DisplayModeConfiguration) async -> Int32 {
  let candidates: [DisplayCandidate]
  do {
    candidates = try await DisplayDiscovery.currentCandidates()
  } catch {
    fputs("error: display inventory failed: \(error.localizedDescription)\n", stderr)
    return 69
  }

  let selected: DisplayCandidate
  do {
    selected = try DisplayDiscovery.select(
      candidates: candidates,
      displayID: configuration.displayID,
      expectedWidth: configuration.expectedDisplayWidth,
      expectedHeight: configuration.expectedDisplayHeight
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
      crop: configuration.normalizedCrop
    )
  } catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    return 64
  }
  let cropEnd = DispatchTime.now().uptimeNanoseconds

  let mapping: AspectMapping
  do {
    mapping = try AspectMapping.centeredCover(
      requestedSourceRect: requestedSourceRect,
      displayWidth: selected.fact.width,
      displayHeight: selected.fact.height,
      destination: configuration.destination
    )
  } catch {
    fputs("error: \(error.localizedDescription)\n", stderr)
    return 64
  }
  let aspectEnd = DispatchTime.now().uptimeNanoseconds

  print(
    "MODE value=explicit-display SELECTION display_id=\(selected.fact.displayID) "
      + "width=\(selected.fact.width) height=\(selected.fact.height) "
      + "unit=screen-points main=\(selected.fact.isMain)"
  )
  print(
    "CROP normalized=\(format(configuration.normalizedCrop)) "
      + "requested_points=\(DisplayDiscovery.format(requestedSourceRect)) "
      + "effective_points=\(mapping.effectiveSourceRect) policy=\(mapping.policy.rawValue)"
  )
  printAspect(mapping)
  printOutput(configuration.destination)
  print(
    "GUARD required_running_and_frontmost_bundle_id="
      + configuration.requiredFrontmostBundleIdentifier
  )

  let initialGuard = SourceValidityGate.evaluate(
    requiredBundleIdentifier: configuration.requiredFrontmostBundleIdentifier,
    snapshot: SourceValidityGate.observe()
  )

  do {
    let client = try ExternalRasterProtocolClient(
      port: configuration.port,
      tokenFile: configuration.tokenFile
    )
    let coordinator = CaptureOutputCoordinator(
      client: client,
      destination: configuration.destination
    )
    let capture = try DisplayCropCapture(
      candidate: selected,
      configuration: configuration,
      mapping: mapping,
      generation: 1,
      initialGuardValid: initialGuard.isValid,
      cropCalculationNanoseconds: cropEnd - cropStart,
      aspectCalculationNanoseconds: aspectEnd - cropEnd,
      outputCoordinator: coordinator
    )
    let metadata = capture.metadata
    print(
      "SCK content_rect_points=\(DisplayDiscovery.format(metadata.filterContentRect)) "
        + String(format: "point_pixel_scale=%.6f ", metadata.pointPixelScale)
        + "source_rect_points=\(metadata.mapping.effectiveSourceRect) "
        + "output_pixels=\(configuration.destination.width)x\(configuration.destination.height) "
        + "preserves_aspect=true scales_to_fit=true cursor=false queue_depth=2 fps="
        + String(metadata.fps)
    )

    let application = DisplayCaptureApplication(
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

@MainActor
private func runProfileMode(
  _ configuration: ProfileModeConfiguration,
  profile: VisualProfile
) async -> Int32 {
  print(
    "MODE value=window-profile profile_id=\(profile.id) "
      + "owner_bundle_id=\(profile.window.ownerBundleIdentifier) "
      + "title_contains=\(profile.window.titleContains.map(quoted) ?? "none") "
      + String(
        format: "minimum_points=%.3fx%.3f ",
        profile.window.minimumWidthPoints,
        profile.window.minimumHeightPoints
      )
      + "crop_normalized=\(format(profile.crop)) policy=\(profile.aspectPolicy.rawValue)"
  )
  printOutput(profile.destination)
  print("GUARD unique_window=true frontmost_required=false physical_origin_identity=false")

  do {
    let client = try ExternalRasterProtocolClient(
      port: configuration.port,
      tokenFile: configuration.tokenFile
    )
    let coordinator = CaptureOutputCoordinator(
      client: client,
      destination: profile.destination
    )
    let application = WindowCaptureApplication(
      profile: profile,
      outputCoordinator: coordinator
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
    "PERMISSION preflight=denied request=\(granted ? "granted" : "denied") attribution=helper-app"
  )
  return granted ? .grantedNeedsRelaunch : .denied
}

private func reportInvalidConfiguration(_ error: Error) {
  fputs(
    "STATE value=\(SourceState.invalidConfiguration.rawValue)\n"
      + "error: \(error.localizedDescription)\n\(CaptureConfiguration.usage)\n",
    stderr
  )
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

private func printAspect(_ mapping: AspectMapping) {
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
}

private func printOutput(_ destination: PushDestination) {
  print(
    "OUTPUT destination=\(destination.x),\(destination.y),\(destination.width),"
      + "\(destination.height) stride=\(destination.stride) "
      + "payload_bytes=\(destination.payloadBytes) "
      + "pixel_format=OPAQUE_BGRA8888 row_order=top-to-bottom"
  )
}

private func quoted(_ value: String) -> String {
  "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""
}

_ = NSApplication.shared.setActivationPolicy(.accessory)
Task { @MainActor in exit(await runMain()) }
NSApplication.shared.run()
