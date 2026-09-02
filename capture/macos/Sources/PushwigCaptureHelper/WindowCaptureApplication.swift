// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation

@MainActor
final class WindowCaptureApplication {
  private let profile: VisualProfile
  private let outputCoordinator: CaptureOutputCoordinator
  private var capture: WindowRelativeCapture?
  private var currentState: SourceState?
  private var stopRequested = false
  private var finished = false
  private var nextGeneration: UInt64 = 1
  private var discoveryPolls: UInt64 = 0
  private var permissionRevalidations: UInt64 = 0
  private var windowLosses: UInt64 = 0
  private var resizeReconfigurations: UInt64 = 0
  private var windowRecreations: UInt64 = 0
  private var moveObservations: UInt64 = 0
  private var lastObservedFrame: CGRect?
  private var lastSelectionDescription: String?
  private var authorityLossNanoseconds: UInt64?

  init(profile: VisualProfile, outputCoordinator: CaptureOutputCoordinator) {
    self.profile = profile
    self.outputCoordinator = outputCoordinator
  }

  func requestStop() {
    stopRequested = true
  }

  func run() async throws {
    do {
      transition(to: .windowUnavailable, detail: "awaiting unique profile match")
      while !stopRequested {
        if let failure = outputCoordinator.failureDescription() {
          transition(to: .disconnected, detail: bounded(failure))
          throw CaptureApplicationError.outputFailed(failure)
        }

        if let failure = capture?.captureFailure() {
          await loseCurrent(reason: "stream-failure \(bounded(failure))")
          transition(to: .captureFailed, detail: bounded(failure))
        }

        try await discoverAndReconcile()
        discoveryPolls += 1
        if discoveryPolls % CaptureConfiguration.windowPermissionRevalidationPollInterval == 0 {
          permissionRevalidations += 1
          if !CGPreflightScreenCaptureAccess() {
            await loseCurrent(reason: "permission-unavailable")
            transition(to: .permissionUnavailable, detail: "runtime permission unavailable")
            throw CaptureApplicationError.permissionDenied
          }
        }
        try await Task.sleep(nanoseconds: CaptureConfiguration.windowDiscoveryPollNanoseconds)
      }
      await finish()
    } catch {
      await finish()
      throw error
    }
  }

  private func discoverAndReconcile() async throws {
    let candidates: [WindowCandidate]
    do {
      candidates = try await WindowDiscovery.currentCandidates(
        ownerBundleIdentifier: profile.window.ownerBundleIdentifier
      )
    } catch {
      await loseCurrent(reason: "window-inventory-unavailable")
      transition(to: .windowUnavailable, detail: "window inventory unavailable")
      return
    }

    let resolved = WindowDiscovery.select(candidates: candidates, selector: profile.window)
    switch resolved.selection {
    case .missing:
      reportSelection("missing", candidateCount: 0)
      await loseCurrent(reason: "no-eligible-window")
      transition(to: .windowUnavailable, detail: "eligible_candidates=0")
    case .ambiguous(let count):
      reportSelection("ambiguous", candidateCount: count)
      await loseCurrent(reason: "ambiguous-window-selection")
      transition(to: .windowAmbiguous, detail: "eligible_candidates=\(count)")
    case .selected:
      guard let candidate = resolved.candidate else {
        reportSelection("missing-capture-object", candidateCount: 0)
        await loseCurrent(reason: "selected-window-has-no-capture-object")
        transition(to: .windowUnavailable, detail: "selected capture object unavailable")
        return
      }
      reportSelection("unique", candidateCount: 1)
      try await reconcileSelected(candidate)
    }
  }

  private func reconcileSelected(_ candidate: WindowCandidate) async throws {
    let newSignature = WindowCaptureSignature(fact: candidate.fact)
    if let current = capture {
      if current.signature == newSignature {
        if let previous = lastObservedFrame,
          previous.origin != candidate.fact.frame.origin
        {
          moveObservations += 1
          print(
            "WINDOW_MOVE window_id=\(candidate.fact.windowID) generation=\(current.metadata.generation) "
              + "from_points=\(WindowDiscovery.format(previous)) "
              + "to_points=\(WindowDiscovery.format(candidate.fact.frame)) "
              + "global_position_ignored=true"
          )
        }
        lastObservedFrame = candidate.fact.frame
        transition(
          to: .capturing,
          detail: "window_id=\(candidate.fact.windowID) generation=\(current.metadata.generation)"
        )
        return
      }

      let sameWindow = current.signature.windowID == newSignature.windowID
      let start = DispatchTime.now().uptimeNanoseconds
      await loseCurrent(reason: sameWindow ? "supported-resize" : "window-recreated")
      try await acquire(candidate, recreation: !sameWindow)
      let duration = DispatchTime.now().uptimeNanoseconds - start
      if sameWindow {
        resizeReconfigurations += 1
        outputCoordinator.recordResizeReconfiguration(nanoseconds: duration)
      }
      return
    }

    try await acquire(candidate, recreation: authorityLossNanoseconds != nil)
  }

  private func acquire(_ candidate: WindowCandidate, recreation: Bool) async throws {
    guard nextGeneration <= UInt64(Int64.max) else {
      throw CaptureConfigurationError.invalid("window capture generation exhausted")
    }
    let generation = nextGeneration
    nextGeneration += 1
    let newCapture: WindowRelativeCapture
    do {
      newCapture = try WindowRelativeCapture(
        candidate: candidate,
        profile: profile,
        generation: generation,
        outputCoordinator: outputCoordinator
      )
    } catch {
      transition(to: .captureFailed, detail: bounded(error.localizedDescription))
      return
    }
    printCaptureMetadata(newCapture.metadata, event: "WINDOW_CONFIGURE")
    do {
      try await newCapture.start()
    } catch {
      await newCapture.stop()
      transition(to: .captureFailed, detail: bounded(error.localizedDescription))
      return
    }

    capture = newCapture
    lastObservedFrame = candidate.fact.frame
    if recreation { windowRecreations += 1 }
    if let lostAt = authorityLossNanoseconds {
      let latency = DispatchTime.now().uptimeNanoseconds - lostAt
      outputCoordinator.recordReacquisition(nanoseconds: latency)
      authorityLossNanoseconds = nil
    }
    printCaptureMetadata(newCapture.metadata, event: "WINDOW_ACQUIRE")
    transition(
      to: .capturing,
      detail: "window_id=\(candidate.fact.windowID) generation=\(generation)"
    )
  }

  private func loseCurrent(reason: String) async {
    guard let current = capture else { return }
    capture = nil
    lastObservedFrame = nil
    authorityLossNanoseconds = DispatchTime.now().uptimeNanoseconds
    windowLosses += 1
    print(
      "WINDOW_LOSS window_id=\(current.metadata.windowFact.windowID) "
        + "generation=\(current.metadata.generation) reason=\(reason)"
    )
    await current.stop()
  }

  private func reportSelection(_ status: String, candidateCount: Int) {
    let description = "\(status):\(candidateCount)"
    guard description != lastSelectionDescription else { return }
    lastSelectionDescription = description
    print(
      "WINDOW_SELECTION profile_id=\(profile.id) status=\(status) "
        + "eligible_candidates=\(candidateCount)"
    )
  }

  private func printCaptureMetadata(_ metadata: WindowCaptureMetadata, event: String) {
    print(
      "\(event) profile_id=\(profile.id) window_id=\(metadata.windowFact.windowID) "
        + "generation=\(metadata.generation) "
        + "frame_points=\(WindowDiscovery.format(metadata.windowFact.frame)) "
        + "content_rect_points=\(WindowDiscovery.format(metadata.filterContentRect)) "
        + String(format: "point_pixel_scale=%.6f ", metadata.pointPixelScale)
        + "requested_points=\(DisplayDiscovery.format(metadata.mapping.requestedSourceRect)) "
        + "effective_points=\(metadata.mapping.effectiveSourceRect) "
        + "helper_crop_local_points="
        + "\(WindowDiscovery.format(metadata.windowLocalEffectiveSourceRect)) "
        + "full_window_output_pixels=\(metadata.fullWindowCaptureSizing.width)x"
        + "\(metadata.fullWindowCaptureSizing.height) "
        + String(
          format: "point_to_output_scale=%.6f,%.6f ",
          metadata.fullWindowCaptureSizing.pointToPixelScaleX,
          metadata.fullWindowCaptureSizing.pointToPixelScaleY
        )
        + "helper_crop_pixels=\(metadata.pixelPlan.mapping.effectiveSourceRect) "
        + "sck_single_window_source_rect=unused "
        + "destination=\(profile.destination.x),\(profile.destination.y),"
        + "\(profile.destination.width),\(profile.destination.height) fps=\(profile.fps)"
    )
  }

  private func finish() async {
    guard !finished else { return }
    finished = true
    transition(to: .stopping, detail: "normal authority revocation")
    await loseCurrent(reason: "helper-stop")
    print(
      "WINDOW_CONTROL_LOOP discovery_polls=\(discoveryPolls) "
        + "permission_revalidations=\(permissionRevalidations) window_losses=\(windowLosses) "
        + "resize_reconfigurations=\(resizeReconfigurations) "
        + "window_recreations=\(windowRecreations) move_observations=\(moveObservations)"
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
