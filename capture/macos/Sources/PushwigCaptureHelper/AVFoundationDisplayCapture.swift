// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AVFoundation
import CoreMedia
import CoreVideo
import CryptoKit
import Foundation
import PushwigFrameCore

private let avFoundationMaximumWidthPixels = 2_560
private let avFoundationMaximumHeightPixels = 1_600
private let avFoundationMaximumPixels = 4_096_000
private let avFoundationMetricWarmupFrames: UInt64 = 100
private let avFoundationMaximumMetricSamples = 20_000

private struct AVFoundationMetricSeries {
  private var values = [UInt64](repeating: 0, count: avFoundationMaximumMetricSamples)
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

  func report(_ name: String) -> String {
    guard count > 0 else { return "METRIC name=\(name) samples=0 overflow=\(overflow)" }
    var sorted = Array(values[0..<count])
    sorted.sort()
    return String(
      format: "METRIC name=%@ samples=%d overflow=%d p50_ms=%.6f p95_ms=%.6f max_ms=%.6f",
      name, count, overflow,
      Double(sorted[(count - 1) * 50 / 100]) / 1_000_000,
      Double(sorted[(count - 1) * 95 / 100]) / 1_000_000,
      Double(sorted[count - 1]) / 1_000_000
    )
  }
}

private struct AVFoundationCaptureMetrics {
  var callbackInterval = AVFoundationMetricSeries()
  var pixelBufferAccess = AVFoundationMetricSeries()
  var portableCropScale = AVFoundationMetricSeries()
  var protocolHeader = AVFoundationMetricSeries()
  var socketSend = AVFoundationMetricSeries()
  var acceptedFrameToSend = AVFoundationMetricSeries()
  var callbacks: UInt64 = 0
  var completeFrames: UInt64 = 0
  var guardSuppressed: UInt64 = 0
  var lateFramesDropped: UInt64 = 0
  var invalidFrames: UInt64 = 0
  var protocolFailures: UInt64 = 0
  var authorityRevocations: UInt64 = 0
  var sourceWidth = 0
  var sourceHeight = 0
  var sourceStride = 0
  var firstOutputHash: String?
  var lastCallback: UInt64?
}

/// AVFoundation display acquisition for the V5 source-family bakeoff. The
/// backend yields a complete BGRA display frame with the system cursor disabled;
/// portable crop/scale/alpha work is delegated to PushwigFrameCore.
final class AVFoundationOutputCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate,
  DisplayOutputManaging
{
  let queue = DispatchQueue(
    label: "com.kasselvania.pushwig.avfoundation-output",
    qos: .userInteractive
  )

  private let client: ExternalRasterProtocolClient
  private let destination: PushDestination
  private let crop: NormalizedCrop
  private let sourceID: UInt64
  private let generation: UInt64
  private var outputBuffer: [UInt8]
  private var authority = VisualAuthorityState()
  private var metrics = AVFoundationCaptureMetrics()
  private var sourceSequence: UInt64 = 0
  private var fatalErrorDescription: String?

  init(
    client: ExternalRasterProtocolClient,
    destination: PushDestination,
    crop: NormalizedCrop,
    sourceID: UInt64,
    generation: UInt64
  ) {
    self.client = client
    self.destination = destination
    self.crop = crop
    self.sourceID = sourceID
    self.generation = generation
    outputBuffer = [UInt8](repeating: 0, count: destination.payloadBytes)
  }

  func activate(guardValid: Bool) {
    queue.sync {
      _ = authority.setCaptureActive(true)
      _ = authority.setGuardValid(guardValid)
    }
  }

  func setGuardDecision(_ decision: SourceValidityDecision) {
    queue.sync {
      if authority.setGuardValid(decision.isValid) { clearCurrentAuthority() }
    }
  }

  func deactivateAndClear() {
    queue.sync {
      if authority.setCaptureActive(false) { clearCurrentAuthority() }
    }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    dispatchPrecondition(condition: .onQueue(queue))
    let callbackStart = DispatchTime.now().uptimeNanoseconds
    metrics.callbacks += 1
    if let previous = metrics.lastCallback, metrics.completeFrames >= avFoundationMetricWarmupFrames
    {
      metrics.callbackInterval.record(callbackStart - previous)
    }
    metrics.lastCallback = callbackStart
    guard authority.mayPublish else {
      metrics.guardSuppressed += 1
      return
    }
    guard CMSampleBufferDataIsReady(sampleBuffer), let pixelBuffer = sampleBuffer.imageBuffer,
      CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA
    else {
      metrics.invalidFrames += 1
      return
    }
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let stride = CVPixelBufferGetBytesPerRow(pixelBuffer)
    guard width > 0, height > 0, stride >= width * 4,
      width <= avFoundationMaximumWidthPixels,
      height <= avFoundationMaximumHeightPixels,
      width * height <= avFoundationMaximumPixels
    else {
      metrics.invalidFrames += 1
      markFatal(
        CaptureConfigurationError.invalid("AVFoundation exceeded the bounded raw-frame dimensions"))
      return
    }
    let accessStart = DispatchTime.now().uptimeNanoseconds
    guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess,
      let source = CVPixelBufferGetBaseAddress(pixelBuffer)
    else {
      metrics.invalidFrames += 1
      return
    }
    let accessEnd = DispatchTime.now().uptimeNanoseconds
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    guard sourceSequence < UInt64(Int64.max) else {
      markFatal(ExternalRasterProtocolError.sequenceExhausted)
      return
    }
    sourceSequence += 1
    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    let timestampNanoseconds: UInt64
    if timestamp.isValid, timestamp.timescale > 0, timestamp.value >= 0 {
      timestampNanoseconds = UInt64(
        Double(timestamp.value) / Double(timestamp.timescale) * 1_000_000_000)
    } else {
      timestampNanoseconds = callbackStart
    }
    var rawFrame = PWRawFrame(
      source_id: sourceID,
      generation: generation,
      sequence: sourceSequence,
      monotonic_timestamp_nanoseconds: timestampNanoseconds,
      width: UInt32(width),
      height: UInt32(height),
      stride: stride,
      pixel_format: PW_PIXEL_FORMAT_BGRA8888,
      complete: true,
      bytes: source.assumingMemoryBound(to: UInt8.self),
      byte_capacity: stride * height
    )
    let portableCrop = PWNormalizedCrop(
      x: crop.x, y: crop.y, width: crop.width, height: crop.height)
    let portableDestination = PWDestination(
      width: UInt32(destination.width),
      height: UInt32(destination.height),
      stride: destination.stride)
    var transformResult = PWTransformResult()
    let transformStart = DispatchTime.now().uptimeNanoseconds
    let status = outputBuffer.withUnsafeMutableBytes { bytes in
      pw_transform_to_opaque_bgra(
        &rawFrame,
        portableCrop,
        portableDestination,
        bytes.bindMemory(to: UInt8.self).baseAddress,
        bytes.count,
        &transformResult
      )
    }
    let transformEnd = DispatchTime.now().uptimeNanoseconds
    guard status == PW_STATUS_OK else {
      metrics.invalidFrames += 1
      markFatal(
        CaptureConfigurationError.invalid(
          "portable frame transform failed status=\(status.rawValue)"))
      return
    }

    do {
      let sendTiming = try client.sendFrame(destination: destination, pixels: outputBuffer)
      let sendEnd = DispatchTime.now().uptimeNanoseconds
      authority.markFramePublished()
      let postWarmup = metrics.completeFrames >= avFoundationMetricWarmupFrames
      metrics.completeFrames += 1
      metrics.sourceWidth = width
      metrics.sourceHeight = height
      metrics.sourceStride = stride
      if postWarmup {
        metrics.pixelBufferAccess.record(accessEnd - accessStart)
        metrics.portableCropScale.record(transformEnd - transformStart)
        metrics.protocolHeader.record(sendTiming.headerPreparationNanoseconds)
        metrics.socketSend.record(sendTiming.socketSendNanoseconds)
        metrics.acceptedFrameToSend.record(sendEnd - callbackStart)
      }
      if metrics.firstOutputHash == nil {
        metrics.firstOutputHash = SHA256.hash(data: outputBuffer).map {
          String(format: "%02x", $0)
        }.joined()
      }
    } catch {
      metrics.protocolFailures += 1
      markFatal(error)
    }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didDrop sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    dispatchPrecondition(condition: .onQueue(queue))
    metrics.lateFramesDropped += 1
  }

  func failureDescription() -> String? {
    queue.sync { fatalErrorDescription }
  }

  func shutdown() -> String {
    queue.sync {
      if authority.setCaptureActive(false) { clearCurrentAuthority() }
      let protocolSnapshot = client.snapshot()
      client.close()
      _ = outputBuffer.withUnsafeMutableBytes {
        $0.initializeMemory(as: UInt8.self, repeating: 0)
      }
      return [
        metrics.callbackInterval.report("avf_callback_interval"),
        metrics.pixelBufferAccess.report("avf_pixel_buffer_access"),
        metrics.portableCropScale.report("portable_crop_scale_opaque_bgra"),
        metrics.protocolHeader.report("protocol_header_prepare"),
        metrics.socketSend.report("loopback_socket_send"),
        metrics.acceptedFrameToSend.report("accepted_source_frame_to_send"),
        "COUNTERS callbacks=\(metrics.callbacks) complete_frames=\(metrics.completeFrames) "
          + "guard_suppressed=\(metrics.guardSuppressed) avf_late_drops=\(metrics.lateFramesDropped) "
          + "invalid_frames=\(metrics.invalidFrames) protocol_failures=\(metrics.protocolFailures) "
          + "authority_revocations=\(metrics.authorityRevocations)",
        "PIXELS source_dimensions=\(metrics.sourceWidth)x\(metrics.sourceHeight) "
          + "source_stride=\(metrics.sourceStride) output_stride=\(destination.stride) "
          + "output_bytes=\(destination.payloadBytes) first_output_sha256="
          + "\(metrics.firstOutputHash ?? "none")",
        "PROTOCOL first_sequence=\(protocolSnapshot.firstFrameSequence.map(String.init) ?? "none") "
          + "last_sequence=\(protocolSnapshot.lastSequence) frames_sent="
          + "\(protocolSnapshot.framesSent) clears_sent=\(protocolSnapshot.clearsSent)",
        "TOPOLOGY avf_discards_late=true application_frame_queues=0 "
          + "output_serial_queues=1 reusable_output_buffers=1",
      ].joined(separator: "\n")
    }
  }

  private func clearCurrentAuthority() {
    do {
      if try client.sendClearIfNeeded() != nil { metrics.authorityRevocations += 1 }
    } catch {
      metrics.protocolFailures += 1
      markFatal(error)
    }
  }

  private func markFatal(_ error: Error) {
    fatalErrorDescription =
      fatalErrorDescription
      ?? String(error.localizedDescription.prefix(240))
  }
}

struct AVFoundationDisplayMetadata {
  let displayFact: DisplayFact
  let nativeWidthPixels: Int
  let nativeHeightPixels: Int
  let captureScale: CGFloat
  let fps: Int
}

enum AVFoundationCaptureSizing {
  static func scale(nativeWidth: Int, nativeHeight: Int) throws -> Double {
    guard nativeWidth > 0, nativeHeight > 0,
      nativeWidth <= 32_768, nativeHeight <= 32_768
    else {
      throw CaptureConfigurationError.invalid("AVFoundation display pixel geometry is unavailable")
    }
    return min(
      1,
      Double(avFoundationMaximumWidthPixels) / Double(nativeWidth),
      Double(avFoundationMaximumHeightPixels) / Double(nativeHeight),
      sqrt(Double(avFoundationMaximumPixels) / Double(nativeWidth * nativeHeight))
    )
  }
}

private final class AVFoundationFailureState: @unchecked Sendable {
  private let lock = NSLock()
  private var message: String?

  func record(_ detail: String) {
    lock.withLock { message = message ?? String(detail.prefix(240)) }
  }

  func read() -> String? {
    lock.withLock { message }
  }
}

final class AVFoundationDisplayCapture: NSObject, ManagedDisplayCapturing {
  let metadata: AVFoundationDisplayMetadata
  var selectedDisplayFact: DisplayFact { metadata.displayFact }
  var metadataDescription: String {
    String(
      format: "AVFOUNDATION api=AVCaptureScreenInput display_id=%u native_pixels=%dx%d "
        + "capture_scale=%.6f cursor=false mouse_clicks=false discards_late=true fps=%d",
      metadata.displayFact.displayID,
      metadata.nativeWidthPixels,
      metadata.nativeHeightPixels,
      metadata.captureScale,
      metadata.fps
    )
  }

  private let session = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  private let screenInput: AVCaptureScreenInput
  private let outputCoordinator: AVFoundationOutputCoordinator
  private let failureState = AVFoundationFailureState()
  private var runtimeObserver: NSObjectProtocol?
  private var started = false

  init(
    candidate: DisplayCandidate,
    configuration: DisplayModeConfiguration,
    initialGuardValid: Bool,
    outputCoordinator: AVFoundationOutputCoordinator
  ) throws {
    guard candidate.fact.displayID == configuration.displayID,
      let input = AVCaptureScreenInput(displayID: configuration.displayID)
    else {
      throw CaptureConfigurationError.invalid("AVFoundation rejected the selected display")
    }
    // The mode's backing-pixel dimensions include HiDPI scale. Display point
    // bounds (and CGDisplayPixelsWide on this scaled fixture) do not suffice.
    guard let displayMode = CGDisplayCopyDisplayMode(configuration.displayID) else {
      throw CaptureConfigurationError.invalid("AVFoundation display mode is unavailable")
    }
    let nativeWidth = displayMode.pixelWidth
    let nativeHeight = displayMode.pixelHeight
    let scale = try AVFoundationCaptureSizing.scale(
      nativeWidth: nativeWidth, nativeHeight: nativeHeight)
    input.scaleFactor = CGFloat(scale)
    input.minFrameDuration = CMTime(value: 1, timescale: CMTimeScale(configuration.fps))
    input.capturesCursor = false
    input.capturesMouseClicks = false

    screenInput = input
    self.outputCoordinator = outputCoordinator
    metadata = AVFoundationDisplayMetadata(
      displayFact: candidate.fact,
      nativeWidthPixels: nativeWidth,
      nativeHeightPixels: nativeHeight,
      captureScale: CGFloat(scale),
      fps: configuration.fps
    )
    super.init()

    session.beginConfiguration()
    guard session.canAddInput(screenInput) else {
      session.commitConfiguration()
      throw CaptureConfigurationError.invalid("AVFoundation session cannot add screen input")
    }
    session.addInput(screenInput)
    videoOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.setSampleBufferDelegate(outputCoordinator, queue: outputCoordinator.queue)
    guard session.canAddOutput(videoOutput) else {
      session.commitConfiguration()
      throw CaptureConfigurationError.invalid("AVFoundation session cannot add raw video output")
    }
    session.addOutput(videoOutput)
    session.commitConfiguration()
    outputCoordinator.activate(guardValid: initialGuardValid)
  }

  func start() async throws {
    session.startRunning()
    guard session.isRunning else {
      outputCoordinator.deactivateAndClear()
      throw CaptureApplicationError.captureFailed("AVFoundation session did not start")
    }
    started = true
    runtimeObserver = NotificationCenter.default.addObserver(
      forName: .AVCaptureSessionRuntimeError,
      object: session,
      queue: nil
    ) { [failureState] notification in
      let detail =
        (notification.userInfo?[AVCaptureSessionErrorKey] as? Error)?
        .localizedDescription ?? "AVFoundation runtime error"
      failureState.record(detail)
    }
  }

  func stop() async {
    outputCoordinator.deactivateAndClear()
    videoOutput.setSampleBufferDelegate(nil, queue: nil)
    if started {
      session.stopRunning()
      started = false
    }
    if let runtimeObserver {
      NotificationCenter.default.removeObserver(runtimeObserver)
      self.runtimeObserver = nil
    }
  }

  func updateGuard(_ decision: SourceValidityDecision) {
    outputCoordinator.setGuardDecision(decision)
  }

  func captureFailure() -> String? {
    failureState.read()
  }
}
