// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreMedia
import CoreVideo
import CryptoKit
import Foundation
import ScreenCaptureKit

private let maximumMetricSamples = 20_000
private let metricWarmupFrames: UInt64 = 100

struct VisualAuthorityState: Equatable {
  private(set) var captureActive = false
  private(set) var guardValid = false
  private(set) var publishedAuthority = false

  mutating func setCaptureActive(_ active: Bool) -> Bool {
    captureActive = active
    return revokeIfIneligible()
  }

  mutating func setGuardValid(_ valid: Bool) -> Bool {
    guardValid = valid
    return revokeIfIneligible()
  }

  mutating func markFramePublished() {
    precondition(captureActive && guardValid)
    publishedAuthority = true
  }

  var mayPublish: Bool { captureActive && guardValid }

  private mutating func revokeIfIneligible() -> Bool {
    guard !mayPublish, publishedAuthority else { return false }
    publishedAuthority = false
    return true
  }
}

enum BGRANormalizerError: LocalizedError, Equatable {
  case invalidGeometry
  case insufficientSource
  case invalidDestination

  var errorDescription: String? {
    switch self {
    case .invalidGeometry: return "invalid BGRA geometry"
    case .insufficientSource: return "source BGRA rows are shorter than declared"
    case .invalidDestination: return "destination BGRA buffer has the wrong size"
    }
  }
}

enum BGRANormalizer {
  static func copyOpaque(
    source: UnsafeRawPointer,
    sourceBytesPerRow: Int,
    width: Int,
    height: Int,
    destination: inout [UInt8]
  ) throws {
    guard width > 0, height > 0,
      width <= Int.max / 4,
      sourceBytesPerRow >= width * 4
    else {
      throw BGRANormalizerError.invalidGeometry
    }
    let usefulRowBytes = width * 4
    guard height <= Int.max / usefulRowBytes else {
      throw BGRANormalizerError.invalidGeometry
    }
    guard destination.count == usefulRowBytes * height else {
      throw BGRANormalizerError.invalidDestination
    }

    destination.withUnsafeMutableBytes { output in
      let outputBytes = output.bindMemory(to: UInt8.self)
      for row in 0..<height {
        let sourceRow = source.advanced(by: row * sourceBytesPerRow)
        let outputOffset = row * usefulRowBytes
        memcpy(output.baseAddress!.advanced(by: outputOffset), sourceRow, usefulRowBytes)
        var alphaOffset = outputOffset + 3
        let rowEnd = outputOffset + usefulRowBytes
        while alphaOffset < rowEnd {
          outputBytes[alphaOffset] = 0xFF
          alphaOffset += 4
        }
      }
    }
  }

  static func hasOnlyOpaqueAlpha(_ bytes: [UInt8]) -> Bool {
    guard bytes.count % 4 == 0 else { return false }
    return bytes.withUnsafeBytes { rawBytes in
      let pixels = rawBytes.bindMemory(to: UInt8.self)
      var index = 3
      while index < pixels.count {
        if pixels[index] != 0xFF { return false }
        index += 4
      }
      return true
    }
  }
}

private struct FixedNanosecondSeries {
  private var values = [UInt64](repeating: 0, count: maximumMetricSamples)
  private(set) var count = 0
  private(set) var overflow = 0

  mutating func record(_ value: UInt64) {
    guard count < values.count else {
      overflow += 1
      return
    }
    values[count] = value
    count += 1
  }

  func summary(name: String) -> String {
    guard count > 0 else {
      return "METRIC name=\(name) samples=0 overflow=\(overflow)"
    }
    var sorted = Array(values[0..<count])
    sorted.sort()
    let p50 = sorted[(count - 1) * 50 / 100]
    let p95 = sorted[(count - 1) * 95 / 100]
    let maximum = sorted[count - 1]
    return String(
      format: "METRIC name=%@ samples=%d overflow=%d p50_ms=%.6f p95_ms=%.6f max_ms=%.6f",
      name,
      count,
      overflow,
      Double(p50) / 1_000_000,
      Double(p95) / 1_000_000,
      Double(maximum) / 1_000_000
    )
  }
}

private final class CaptureMetrics {
  var callbackInterval = FixedNanosecondSeries()
  var cropScaleDelivery = FixedNanosecondSeries()
  var statusValidation = FixedNanosecondSeries()
  var pixelBufferAccess = FixedNanosecondSeries()
  var copyAndNormalize = FixedNanosecondSeries()
  var protocolHeader = FixedNanosecondSeries()
  var socketSend = FixedNanosecondSeries()
  var copyMapNormalizeSend = FixedNanosecondSeries()
  var acceptedSampleToSend = FixedNanosecondSeries()
  var cropCalculation = FixedNanosecondSeries()
  var aspectCalculation = FixedNanosecondSeries()
  var streamConfiguration = FixedNanosecondSeries()

  var callbacks: UInt64 = 0
  var completeSamples: UInt64 = 0
  var incompleteSamples: UInt64 = 0
  var idleSamples: UInt64 = 0
  var blankSamples: UInt64 = 0
  var suspendedSamples: UInt64 = 0
  var startedSamples: UInt64 = 0
  var stoppedSamples: UInt64 = 0
  var missingStatusSamples: UInt64 = 0
  var invalidPixelBuffers: UInt64 = 0
  var pixelFormatMismatches: UInt64 = 0
  var dimensionMismatches: UInt64 = 0
  var rowStrideMismatches: UInt64 = 0
  var alphaMismatches: UInt64 = 0
  var guardSuppressedSamples: UInt64 = 0
  var authorityRevocations: UInt64 = 0
  var guardValidTransitions: UInt64 = 0
  var guardInvalidTransitions: UInt64 = 0
  var protocolFailures: UInt64 = 0
  var streamFailures: UInt64 = 0
  var fullDisplayPayloads: UInt64 = 0
  var wrongDestinationPublications: UInt64 = 0
  var firstCallback: UInt64?
  var lastCallback: UInt64?
  var lastPixelFormat: OSType = 0
  var lastSourceBytesPerRow = 0
  var firstSourceSHA256: String?
  var firstOutputSHA256: String?
  var finalOutputSHA256: String?

  func report(
    protocolSnapshot: ProtocolClientSnapshot,
    destination: PushDestination,
    outputBuffer: [UInt8]
  ) -> String {
    if !outputBuffer.isEmpty {
      finalOutputSHA256 = Self.sha256(outputBuffer)
    }
    let callbackSpan: Double
    let observedFPS: Double
    if let firstCallback, let lastCallback, lastCallback > firstCallback {
      let seconds = Double(lastCallback - firstCallback) / 1_000_000_000
      callbackSpan = seconds * 1_000
      let callbackIntervals = callbacks > 0 ? callbacks - 1 : 0
      observedFPS = Double(callbackIntervals) / seconds
    } else {
      callbackSpan = 0
      observedFPS = 0
    }
    let postWarmup =
      completeSamples > metricWarmupFrames
      ? completeSamples - metricWarmupFrames
      : 0

    return [
      callbackInterval.summary(name: "callback_interval"),
      cropScaleDelivery.summary(name: "sck_crop_scale_delivery_to_callback"),
      statusValidation.summary(name: "frame_status_validation"),
      pixelBufferAccess.summary(name: "pixel_buffer_lock_access"),
      cropCalculation.summary(name: "normalized_crop_calculation"),
      aspectCalculation.summary(name: "centered_cover_aspect_calculation"),
      streamConfiguration.summary(name: "sck_stream_configuration"),
      copyAndNormalize.summary(name: "bgra_copy_alpha_normalize"),
      protocolHeader.summary(name: "protocol_header_prepare"),
      socketSend.summary(name: "loopback_socket_send"),
      copyMapNormalizeSend.summary(name: "copy_map_normalize_send"),
      acceptedSampleToSend.summary(name: "accepted_sample_to_send"),
      "MEASUREMENT warmup_frames=\(metricWarmupFrames) post_warmup_frames=\(postWarmup) "
        + String(format: "callback_span_ms=%.3f observed_fps=%.3f", callbackSpan, observedFPS),
      "COUNTERS callbacks=\(callbacks) complete_samples=\(completeSamples) "
        + "incomplete_samples=\(incompleteSamples) idle=\(idleSamples) blank=\(blankSamples) "
        + "suspended=\(suspendedSamples) started=\(startedSamples) stopped=\(stoppedSamples) "
        + "missing_status=\(missingStatusSamples) invalid_pixel_buffers=\(invalidPixelBuffers) "
        + "pixel_format_mismatches=\(pixelFormatMismatches) "
        + "dimension_mismatches=\(dimensionMismatches) row_stride_mismatches=\(rowStrideMismatches) "
        + "alpha_mismatches=\(alphaMismatches) guard_suppressed=\(guardSuppressedSamples) "
        + "authority_revocations=\(authorityRevocations) guard_valid_transitions=\(guardValidTransitions) "
        + "guard_invalid_transitions=\(guardInvalidTransitions) protocol_failures=\(protocolFailures) "
        + "stream_failures=\(streamFailures) full_display_payloads=\(fullDisplayPayloads) "
        + "wrong_destination_publications=\(wrongDestinationPublications)",
      "PROTOCOL first_sequence=\(protocolSnapshot.firstFrameSequence.map(String.init) ?? "none") "
        + "last_sequence=\(protocolSnapshot.lastSequence) frames_sent=\(protocolSnapshot.framesSent) "
        + "clears_sent=\(protocolSnapshot.clearsSent)",
      "PIXELS pixel_format=\(Self.fourCC(lastPixelFormat)) source_bytes_per_row=\(lastSourceBytesPerRow) "
        + "output_stride=\(destination.stride) output_bytes=\(destination.payloadBytes) "
        + "buffer_count=1 buffer_capacity=\(outputBuffer.count) "
        + "first_source_sha256=\(firstSourceSHA256 ?? "none") "
        + "first_output_sha256=\(firstOutputSHA256 ?? "none") "
        + "final_output_sha256=\(finalOutputSHA256 ?? "none")",
      "TOPOLOGY capture_outputs=1 application_frame_queues=0 output_serial_queues=1 "
        + "output_buffer_count=1 queue_depth=\(CaptureConfiguration.streamQueueDepth)",
    ].joined(separator: "\n")
  }

  static func sha256(_ bytes: [UInt8]) -> String {
    SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
  }

  private static func fourCC(_ value: OSType) -> String {
    guard value != 0 else { return "none" }
    let bytes = [
      UInt8(truncatingIfNeeded: value >> 24),
      UInt8(truncatingIfNeeded: value >> 16),
      UInt8(truncatingIfNeeded: value >> 8),
      UInt8(truncatingIfNeeded: value),
    ]
    return String(bytes: bytes, encoding: .ascii) ?? String(value)
  }
}

struct DisplayCropMetadata {
  let generation: UInt64
  let displayFact: DisplayFact
  let filterContentRect: CGRect
  let pointPixelScale: Float
  let mapping: AspectMapping
  let fps: Int
}

final class CaptureOutputCoordinator {
  let queue = DispatchQueue(
    label: "com.kasselvania.pushwig.display-crop-output",
    qos: .userInteractive
  )

  private let client: ExternalRasterProtocolClient
  private let destination: PushDestination
  private var outputBuffer: [UInt8]
  private var authority = VisualAuthorityState()
  private var activeGeneration: UInt64?
  private var currentGuardValid = false
  private var lastCallbackNanoseconds: UInt64?
  private var fatalErrorDescription: String?
  private var metrics = CaptureMetrics()

  init(client: ExternalRasterProtocolClient, destination: PushDestination) {
    self.client = client
    self.destination = destination
    outputBuffer = [UInt8](repeating: 0, count: destination.payloadBytes)
  }

  func activate(
    generation: UInt64,
    guardValid: Bool,
    cropCalculationNanoseconds: UInt64,
    aspectCalculationNanoseconds: UInt64,
    streamConfigurationNanoseconds: UInt64
  ) {
    queue.sync {
      activeGeneration = generation
      currentGuardValid = guardValid
      _ = authority.setCaptureActive(true)
      _ = authority.setGuardValid(guardValid)
      lastCallbackNanoseconds = nil
      metrics.cropCalculation.record(cropCalculationNanoseconds)
      metrics.aspectCalculation.record(aspectCalculationNanoseconds)
      metrics.streamConfiguration.record(streamConfigurationNanoseconds)
      if guardValid {
        metrics.guardValidTransitions += 1
      } else {
        metrics.guardInvalidTransitions += 1
      }
    }
  }

  func setGuardDecision(_ decision: SourceValidityDecision) {
    queue.sync {
      guard decision.isValid != currentGuardValid else { return }
      currentGuardValid = decision.isValid
      if decision.isValid {
        metrics.guardValidTransitions += 1
      } else {
        metrics.guardInvalidTransitions += 1
      }
      let shouldClear = authority.setGuardValid(decision.isValid)
      if shouldClear { clearCurrentAuthority() }
    }
  }

  func deactivateAndClear(generation: UInt64) {
    queue.sync {
      guard activeGeneration == generation else { return }
      activeGeneration = nil
      let shouldClear = authority.setCaptureActive(false)
      if shouldClear { clearCurrentAuthority() }
    }
  }

  func recordStreamFailure() {
    queue.async { self.metrics.streamFailures += 1 }
  }

  func failureDescription() -> String? {
    queue.sync { fatalErrorDescription }
  }

  func handle(sampleBuffer: CMSampleBuffer, generation: UInt64) {
    dispatchPrecondition(condition: .onQueue(queue))
    let callbackStart = DispatchTime.now().uptimeNanoseconds
    metrics.callbacks += 1
    metrics.firstCallback = metrics.firstCallback ?? callbackStart
    metrics.lastCallback = callbackStart
    let isPostWarmup = metrics.completeSamples >= metricWarmupFrames
    if isPostWarmup, let previous = lastCallbackNanoseconds {
      metrics.callbackInterval.record(callbackStart - previous)
    }
    lastCallbackNanoseconds = callbackStart

    guard activeGeneration == generation else { return }
    guard authority.mayPublish else {
      metrics.guardSuppressedSamples += 1
      return
    }

    let statusStart = DispatchTime.now().uptimeNanoseconds
    guard let frameInfo = frameInfo(sampleBuffer), let status = frameStatus(frameInfo) else {
      metrics.missingStatusSamples += 1
      return
    }
    guard status == .complete else {
      metrics.incompleteSamples += 1
      switch status {
      case .idle: metrics.idleSamples += 1
      case .blank: metrics.blankSamples += 1
      case .suspended: metrics.suspendedSamples += 1
      case .started: metrics.startedSamples += 1
      case .stopped: metrics.stoppedSamples += 1
      default: break
      }
      return
    }
    let statusEnd = DispatchTime.now().uptimeNanoseconds
    if isPostWarmup {
      metrics.statusValidation.record(statusEnd - statusStart)
      recordCropScaleDelivery(frameInfo: frameInfo)
    }

    guard let pixelBuffer = sampleBuffer.imageBuffer else {
      metrics.invalidPixelBuffers += 1
      return
    }
    let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    metrics.lastPixelFormat = pixelFormat
    metrics.lastSourceBytesPerRow = bytesPerRow
    guard pixelFormat == kCVPixelFormatType_32BGRA else {
      metrics.pixelFormatMismatches += 1
      return
    }
    guard width == destination.width, height == destination.height else {
      metrics.dimensionMismatches += 1
      return
    }
    guard bytesPerRow >= destination.stride else {
      metrics.rowStrideMismatches += 1
      return
    }

    let accessStart = DispatchTime.now().uptimeNanoseconds
    guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
      metrics.invalidPixelBuffers += 1
      return
    }
    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
      metrics.invalidPixelBuffers += 1
      return
    }
    let accessEnd = DispatchTime.now().uptimeNanoseconds
    if isPostWarmup {
      metrics.pixelBufferAccess.record(accessEnd - accessStart)
    }

    let shouldHashFirst = metrics.firstSourceSHA256 == nil
    var sourceHasher = SHA256()
    if shouldHashFirst {
      for row in 0..<destination.height {
        sourceHasher.update(
          bufferPointer: UnsafeRawBufferPointer(
            start: baseAddress.advanced(by: row * bytesPerRow),
            count: destination.stride
          )
        )
      }
    }

    let copyStart = accessEnd
    do {
      try BGRANormalizer.copyOpaque(
        source: baseAddress,
        sourceBytesPerRow: bytesPerRow,
        width: destination.width,
        height: destination.height,
        destination: &outputBuffer
      )
    } catch {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
      metrics.invalidPixelBuffers += 1
      markFatal(error)
      return
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    guard BGRANormalizer.hasOnlyOpaqueAlpha(outputBuffer) else {
      metrics.alphaMismatches += 1
      return
    }
    let copyEnd = DispatchTime.now().uptimeNanoseconds

    do {
      let timing = try client.sendFrame(destination: destination, pixels: outputBuffer)
      let sendEnd = DispatchTime.now().uptimeNanoseconds
      authority.markFramePublished()
      metrics.completeSamples += 1
      if isPostWarmup {
        metrics.copyAndNormalize.record(copyEnd - copyStart)
        metrics.protocolHeader.record(timing.headerPreparationNanoseconds)
        metrics.socketSend.record(timing.socketSendNanoseconds)
        metrics.copyMapNormalizeSend.record(sendEnd - copyStart)
        metrics.acceptedSampleToSend.record(sendEnd - callbackStart)
      }
      if shouldHashFirst {
        metrics.firstSourceSHA256 = sourceHasher.finalize().map {
          String(format: "%02x", $0)
        }.joined()
        metrics.firstOutputSHA256 = CaptureMetrics.sha256(outputBuffer)
      }
    } catch {
      metrics.protocolFailures += 1
      markFatal(error)
    }
  }

  func shutdown() -> String {
    queue.sync {
      activeGeneration = nil
      if authority.setCaptureActive(false) { clearCurrentAuthority() }
      let snapshot = client.snapshot()
      let report = metrics.report(
        protocolSnapshot: snapshot,
        destination: destination,
        outputBuffer: outputBuffer
      )
      client.close()
      _ = outputBuffer.withUnsafeMutableBytes { bytes in
        bytes.initializeMemory(as: UInt8.self, repeating: 0)
      }
      return report
    }
  }

  private func clearCurrentAuthority() {
    do {
      if try client.sendClearIfNeeded() != nil {
        metrics.authorityRevocations += 1
      }
    } catch {
      metrics.protocolFailures += 1
      markFatal(error)
    }
  }

  private func markFatal(_ error: Error) {
    if fatalErrorDescription == nil {
      fatalErrorDescription = String(error.localizedDescription.prefix(240))
    }
  }

  private func frameInfo(_ sampleBuffer: CMSampleBuffer) -> [SCStreamFrameInfo: Any]? {
    guard
      let attachments = CMSampleBufferGetSampleAttachmentsArray(
        sampleBuffer,
        createIfNecessary: false
      ) as? [[SCStreamFrameInfo: Any]],
      let first = attachments.first
    else {
      return nil
    }
    return first
  }

  private func frameStatus(_ frameInfo: [SCStreamFrameInfo: Any]) -> SCFrameStatus? {
    guard let rawValue = frameInfo[.status] as? Int else { return nil }
    return SCFrameStatus(rawValue: rawValue)
  }

  private func recordCropScaleDelivery(frameInfo: [SCStreamFrameInfo: Any]) {
    guard let displayTime = (frameInfo[.displayTime] as? NSNumber)?.uint64Value else { return }
    let presentation = CMClockMakeHostTimeFromSystemUnits(displayTime)
    let hostNow = CMClockGetTime(CMClockGetHostTimeClock())
    let delta = CMTimeSubtract(hostNow, presentation)
    guard delta.isValid, delta.isNumeric, delta.value >= 0 else { return }
    let seconds = CMTimeGetSeconds(delta)
    guard seconds.isFinite, seconds >= 0,
      seconds <= Double(UInt64.max) / 1_000_000_000
    else { return }
    metrics.cropScaleDelivery.record(UInt64(seconds * 1_000_000_000))
  }
}

final class DisplayCropSampleOutput: NSObject, SCStreamOutput {
  private let coordinator: CaptureOutputCoordinator
  private let generation: UInt64

  init(coordinator: CaptureOutputCoordinator, generation: UInt64) {
    self.coordinator = coordinator
    self.generation = generation
  }

  func stream(
    _ stream: SCStream,
    didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
    of outputType: SCStreamOutputType
  ) {
    guard outputType == .screen else { return }
    coordinator.handle(sampleBuffer: sampleBuffer, generation: generation)
  }
}

final class DisplayCropCapture: NSObject, SCStreamDelegate {
  let metadata: DisplayCropMetadata

  private var stream: SCStream!
  private var sampleOutput: DisplayCropSampleOutput!
  private let outputCoordinator: CaptureOutputCoordinator
  private let failureLock = NSLock()
  private var failureMessage: String?
  private var started = false

  init(
    candidate: DisplayCandidate,
    configuration: CaptureConfiguration,
    mapping: AspectMapping,
    generation: UInt64,
    initialGuardValid: Bool,
    cropCalculationNanoseconds: UInt64,
    aspectCalculationNanoseconds: UInt64,
    outputCoordinator: CaptureOutputCoordinator
  ) throws {
    guard let display = candidate.display,
      let fps = configuration.fps,
      let destination = configuration.destination
    else {
      throw CaptureConfigurationError.invalid("display capture configuration is incomplete")
    }

    let configurationStart = DispatchTime.now().uptimeNanoseconds
    let filter = SCContentFilter(display: display, excludingWindows: [])
    // SCDisplay dimensions, SCContentFilter.contentRect, and sourceRect are
    // ScreenCaptureKit screen points. pointPixelScale describes the later
    // point-to-output-pixel relationship; sourceRect must not be multiplied by
    // it.
    guard abs(filter.contentRect.width - Double(candidate.fact.width)) < 0.001,
      abs(filter.contentRect.height - Double(candidate.fact.height)) < 0.001
    else {
      throw CaptureConfigurationError.invalid(
        "ScreenCaptureKit content point dimensions do not match selected display dimensions"
      )
    }
    let sourceRect = mapping.effectiveSourceRect.cgRect
    let displayPointBounds = CGRect(
      x: 0,
      y: 0,
      width: candidate.fact.width,
      height: candidate.fact.height
    )
    guard displayPointBounds.contains(sourceRect),
      sourceRect.width < displayPointBounds.width
        || sourceRect.height < displayPointBounds.height
    else {
      throw CaptureConfigurationError.invalid(
        "bounded effective crop is invalid or equals the whole display"
      )
    }

    let streamConfiguration = SCStreamConfiguration()
    streamConfiguration.width = destination.width
    streamConfiguration.height = destination.height
    streamConfiguration.minimumFrameInterval = CMTime(
      value: 1,
      timescale: CMTimeScale(fps)
    )
    streamConfiguration.pixelFormat = kCVPixelFormatType_32BGRA
    streamConfiguration.scalesToFit = true
    streamConfiguration.preservesAspectRatio = true
    streamConfiguration.showsCursor = false
    if #available(macOS 15.0, *) {
      streamConfiguration.showMouseClicks = false
    }
    streamConfiguration.sourceRect = sourceRect
    streamConfiguration.destinationRect = CGRect(
      x: 0,
      y: 0,
      width: destination.width,
      height: destination.height
    )
    streamConfiguration.queueDepth = CaptureConfiguration.streamQueueDepth
    streamConfiguration.capturesAudio = false
    streamConfiguration.shouldBeOpaque = true

    metadata = DisplayCropMetadata(
      generation: generation,
      displayFact: candidate.fact,
      filterContentRect: filter.contentRect,
      pointPixelScale: filter.pointPixelScale,
      mapping: mapping,
      fps: fps
    )
    self.outputCoordinator = outputCoordinator
    super.init()
    sampleOutput = DisplayCropSampleOutput(
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
      guardValid: initialGuardValid,
      cropCalculationNanoseconds: cropCalculationNanoseconds,
      aspectCalculationNanoseconds: aspectCalculationNanoseconds,
      streamConfigurationNanoseconds: configurationEnd - configurationStart
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

  func updateGuard(_ decision: SourceValidityDecision) {
    outputCoordinator.setGuardDecision(decision)
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
