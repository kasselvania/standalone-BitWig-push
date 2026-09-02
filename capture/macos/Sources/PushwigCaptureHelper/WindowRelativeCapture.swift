// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreMedia
import Foundation
import ScreenCaptureKit

struct WindowCaptureSignature: Equatable {
  let windowID: CGWindowID
  let widthMilliPoints: Int
  let heightMilliPoints: Int

  init(fact: WindowFact) {
    windowID = fact.windowID
    widthMilliPoints = Int((fact.frame.width * 1_000).rounded())
    heightMilliPoints = Int((fact.frame.height * 1_000).rounded())
  }
}

struct WindowCaptureMetadata {
  let profileID: String
  let generation: UInt64
  let windowFact: WindowFact
  let filterContentRect: CGRect
  let pointPixelScale: Float
  let mapping: AspectMapping
  let windowLocalEffectiveSourceRect: CGRect
  let fullWindowCaptureSizing: FullWindowCaptureSizing
  let pixelPlan: WindowFramePlan
  let fps: Int
}

struct WindowRelativeGeometry: Equatable {
  let mapping: AspectMapping
  let windowLocalEffectiveSourceRect: CGRect

  static func make(
    contentRect: CGRect,
    requestedSourceRect: CGRect,
    destination: PushDestination
  ) throws -> WindowRelativeGeometry {
    let mapping = try AspectMapping.centeredCover(
      requestedSourceRect: requestedSourceRect,
      sourceBounds: contentRect,
      destination: destination
    )
    let windowLocalEffectiveSourceRect = mapping.effectiveSourceRect.cgRect.offsetBy(
      dx: -contentRect.minX,
      dy: -contentRect.minY
    )
    let windowLocalBounds = CGRect(origin: .zero, size: contentRect.size)
    guard AspectMapping.contains(windowLocalEffectiveSourceRect, within: windowLocalBounds) else {
      throw CaptureConfigurationError.invalid(
        "window-local source rectangle is outside the capture content bounds"
      )
    }
    return WindowRelativeGeometry(
      mapping: mapping,
      windowLocalEffectiveSourceRect: windowLocalEffectiveSourceRect
    )
  }
}

final class WindowRelativeCapture: NSObject, SCStreamDelegate {
  let signature: WindowCaptureSignature
  let metadata: WindowCaptureMetadata

  private var stream: SCStream!
  private var sampleOutput: CaptureSampleOutput!
  private let outputCoordinator: CaptureOutputCoordinator
  private let failureLock = NSLock()
  private var failureMessage: String?
  private var started = false

  init(
    candidate: WindowCandidate,
    profile: VisualProfile,
    generation: UInt64,
    outputCoordinator: CaptureOutputCoordinator
  ) throws {
    guard let window = candidate.window else {
      throw CaptureConfigurationError.invalid("selected window has no capture object")
    }

    let cropStart = DispatchTime.now().uptimeNanoseconds
    let filter = SCContentFilter(desktopIndependentWindow: window)
    let contentRect = filter.contentRect
    let requestedSourceRect = try AspectMapping.requestedSourceRect(
      sourceBounds: contentRect, crop: profile.crop)
    let cropEnd = DispatchTime.now().uptimeNanoseconds
    let geometry = try WindowRelativeGeometry.make(
      contentRect: contentRect,
      requestedSourceRect: requestedSourceRect,
      destination: profile.destination
    )
    let aspectEnd = DispatchTime.now().uptimeNanoseconds

    let fullWindowCaptureSizing = try FullWindowCaptureSizing.make(
      contentSizePoints: contentRect.size,
      pointPixelScale: filter.pointPixelScale
    )
    let pixelPlan = try WindowFramePlan.make(
      sourceWidth: fullWindowCaptureSizing.width,
      sourceHeight: fullWindowCaptureSizing.height,
      crop: profile.crop,
      destination: profile.destination
    )

    let configurationStart = aspectEnd
    let streamConfiguration = SCStreamConfiguration()
    streamConfiguration.width = fullWindowCaptureSizing.width
    streamConfiguration.height = fullWindowCaptureSizing.height
    streamConfiguration.minimumFrameInterval = CMTime(
      value: 1,
      timescale: CMTimeScale(profile.fps)
    )
    streamConfiguration.pixelFormat = kCVPixelFormatType_32BGRA
    streamConfiguration.scalesToFit = true
    streamConfiguration.preservesAspectRatio = true
    streamConfiguration.showsCursor = false
    if #available(macOS 15.0, *) {
      streamConfiguration.showMouseClicks = false
    }
    // Apple documents that sourceRect is not referenced for a
    // desktopIndependentWindow stream. Capture the complete window at a bounded
    // resolution; CaptureOutputCoordinator performs the explicit local crop.
    streamConfiguration.queueDepth = CaptureConfiguration.streamQueueDepth
    streamConfiguration.capturesAudio = false
    streamConfiguration.ignoreShadowsSingleWindow = true
    streamConfiguration.ignoreGlobalClipSingleWindow = true
    streamConfiguration.shouldBeOpaque = true
    if #available(macOS 14.2, *) {
      streamConfiguration.includeChildWindows = false
    }

    signature = WindowCaptureSignature(fact: candidate.fact)
    metadata = WindowCaptureMetadata(
      profileID: profile.id,
      generation: generation,
      windowFact: candidate.fact,
      filterContentRect: contentRect,
      pointPixelScale: filter.pointPixelScale,
      mapping: geometry.mapping,
      windowLocalEffectiveSourceRect: geometry.windowLocalEffectiveSourceRect,
      fullWindowCaptureSizing: fullWindowCaptureSizing,
      pixelPlan: pixelPlan,
      fps: profile.fps
    )
    self.outputCoordinator = outputCoordinator
    super.init()

    sampleOutput = CaptureSampleOutput(
      coordinator: outputCoordinator,
      generation: generation
    )
    stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
    try stream.addStreamOutput(
      sampleOutput,
      type: .screen,
      sampleHandlerQueue: outputCoordinator.queue
    )
    let configurationEnd = DispatchTime.now().uptimeNanoseconds
    outputCoordinator.activate(
      generation: generation,
      guardValid: true,
      cropCalculationNanoseconds: cropEnd - cropStart,
      aspectCalculationNanoseconds: aspectEnd - cropEnd,
      streamConfigurationNanoseconds: configurationEnd - configurationStart,
      windowFramePlan: pixelPlan
    )
  }

  func start() async throws {
    do {
      try await stream.startCapture()
      started = true
    } catch {
      outputCoordinator.deactivateAndClear(generation: metadata.generation)
      throw error
    }
  }

  func stop() async {
    outputCoordinator.deactivateAndClear(generation: metadata.generation)
    if started {
      do {
        try await stream.stopCapture()
      } catch {
        failureLock.withLock {
          failureMessage = failureMessage ?? String(error.localizedDescription.prefix(240))
        }
      }
      started = false
    }
    do {
      try stream.removeStreamOutput(sampleOutput, type: .screen)
    } catch {
      failureLock.withLock {
        failureMessage = failureMessage ?? String(error.localizedDescription.prefix(240))
      }
    }
  }

  func stream(_ stream: SCStream, didStopWithError error: Error) {
    failureLock.withLock {
      failureMessage = String(error.localizedDescription.prefix(240))
    }
    outputCoordinator.recordStreamFailure()
  }

  func captureFailure() -> String? {
    failureLock.withLock { failureMessage }
  }
}
