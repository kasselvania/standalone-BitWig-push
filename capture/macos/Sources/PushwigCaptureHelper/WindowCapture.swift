// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreMedia
import CoreVideo
import CryptoKit
import Foundation
import ScreenCaptureKit

private let maximumMetricSamples = 20_000
private let metricWarmupCompleteFrames: UInt64 = 100

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
        guard count > 0 else { return "METRIC name=\(name) samples=0 overflow=\(overflow)" }
        var sorted = Array(values[0 ..< count])
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
    var statusAcceptance = FixedNanosecondSeries()
    var pixelBufferAccess = FixedNanosecondSeries()
    var cropConfiguration = FixedNanosecondSeries()
    var copyAndNormalize = FixedNanosecondSeries()
    var protocolHeader = FixedNanosecondSeries()
    var socketSend = FixedNanosecondSeries()
    var sampleToSend = FixedNanosecondSeries()

    var callbackCount: UInt64 = 0
    var completeFrameCount: UInt64 = 0
    var incompleteFrameCount: UInt64 = 0
    var idleFrameCount: UInt64 = 0
    var blankFrameCount: UInt64 = 0
    var suspendedFrameCount: UInt64 = 0
    var startedFrameCount: UInt64 = 0
    var stoppedFrameCount: UInt64 = 0
    var invalidPixelBufferCount: UInt64 = 0
    var cropBoundsFailures: UInt64 = 0
    var pixelFormatMismatches: UInt64 = 0
    var rowStrideMismatches: UInt64 = 0
    var outputAlphaMismatches: UInt64 = 0
    var callbacksRejectedAfterAuthorityLoss: UInt64 = 0
    var framesPublishedAfterAuthorityLoss: UInt64 = 0
    var protocolSendFailures: UInt64 = 0
    var streamFailures: UInt64 = 0
    var firstCallbackNanoseconds: UInt64?
    var lastCallbackNanoseconds: UInt64?
    var lastSourceBytesPerRow = 0
    var lastPixelFormat: OSType = 0
    var firstCroppedSHA256: String?
    var firstOutputSHA256: String?
    var finalOutputSHA256: String?

    func output(protocolSnapshot: ProtocolClientSnapshot, finalBuffer: [UInt8]) -> String {
        if !finalBuffer.isEmpty { finalOutputSHA256 = sha256(finalBuffer) }
        let postWarmupCompleteFrames = completeFrameCount > metricWarmupCompleteFrames
            ? completeFrameCount - metricWarmupCompleteFrames
            : 0
        let uptimeMilliseconds: Double
        if let firstCallbackNanoseconds, let lastCallbackNanoseconds {
            uptimeMilliseconds = Double(lastCallbackNanoseconds - firstCallbackNanoseconds) / 1_000_000
        } else {
            uptimeMilliseconds = 0
        }
        return [
            callbackInterval.summary(name: "callback_interval"),
            statusAcceptance.summary(name: "sample_status_acceptance"),
            pixelBufferAccess.summary(name: "pixel_buffer_lock_access"),
            cropConfiguration.summary(name: "source_crop_configuration"),
            copyAndNormalize.summary(name: "bgra_copy_alpha_normalize"),
            protocolHeader.summary(name: "protocol_header_prepare"),
            socketSend.summary(name: "socket_send"),
            sampleToSend.summary(name: "complete_sample_to_send"),
            "MEASUREMENT warmup_complete_frames=\(metricWarmupCompleteFrames) "
                + "post_warmup_complete_frames=\(postWarmupCompleteFrames)",
            "COUNTERS callbacks=\(callbackCount) complete=\(completeFrameCount) "
                + "incomplete=\(incompleteFrameCount) idle=\(idleFrameCount) blank=\(blankFrameCount) "
                + "suspended=\(suspendedFrameCount) started=\(startedFrameCount) "
                + "stopped=\(stoppedFrameCount) invalid_pixel_buffer=\(invalidPixelBufferCount) "
                + "crop_bounds_failures=\(cropBoundsFailures) pixel_format_mismatches=\(pixelFormatMismatches) "
                + "row_stride_mismatches=\(rowStrideMismatches) alpha_mismatches=\(outputAlphaMismatches) "
                + "callbacks_rejected_after_authority_loss=\(callbacksRejectedAfterAuthorityLoss) "
                + "frames_published_after_authority_loss=\(framesPublishedAfterAuthorityLoss) "
                + "protocol_send_failures=\(protocolSendFailures) stream_failures=\(streamFailures)",
            "PROTOCOL first_sequence=\(protocolSnapshot.firstSequence.map(String.init) ?? "none") "
                + "last_sequence=\(protocolSnapshot.lastSequence) frames_sent=\(protocolSnapshot.framesSent) "
                + "clears_sent=\(protocolSnapshot.clearsSent)",
            "PIXELS pixel_format=\(fourCC(lastPixelFormat)) bytes_per_row=\(lastSourceBytesPerRow) "
                + "first_cropped_sha256=\(firstCroppedSHA256 ?? "none") "
                + "first_output_sha256=\(firstOutputSHA256 ?? "none") "
                + "final_output_sha256=\(finalOutputSHA256 ?? "none") "
                + String(format: "callback_span_ms=%.3f", uptimeMilliseconds)
        ].joined(separator: "\n")
    }

    private func sha256(_ bytes: [UInt8]) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    private func fourCC(_ value: OSType) -> String {
        guard value != 0 else { return "none" }
        let bytes: [UInt8] = [
            UInt8(truncatingIfNeeded: value >> 24),
            UInt8(truncatingIfNeeded: value >> 16),
            UInt8(truncatingIfNeeded: value >> 8),
            UInt8(truncatingIfNeeded: value)
        ]
        return String(bytes: bytes, encoding: .ascii) ?? String(value)
    }
}

struct CaptureSourceMetadata {
    let windowID: CGWindowID
    let generation: UInt64
    let windowFrame: CGRect
    let filterContentRect: CGRect
    let normalizedCrop: NormalizedCrop
    let sourceRect: CGRect
    let pointPixelScale: Float
    let destination: PushDestination
}

final class CaptureOutputCoordinator {
    let queue = DispatchQueue(label: "com.kasselvania.pushwig.capture-output", qos: .userInteractive)

    private let client: ExternalRasterProtocolClient
    private let destination: PushDestination
    private var outputBuffer: [UInt8]
    private var activeGeneration: UInt64?
    private var activeMetadata: CaptureSourceMetadata?
    private var lastCallbackNanoseconds: UInt64?
    private var fatalErrorDescription: String?
    private var metrics = CaptureMetrics()

    init(client: ExternalRasterProtocolClient, destination: PushDestination) {
        self.client = client
        self.destination = destination
        outputBuffer = [UInt8](repeating: 0, count: destination.payloadBytes)
    }

    func activate(metadata: CaptureSourceMetadata, configurationNanoseconds: UInt64) {
        queue.sync {
            activeGeneration = metadata.generation
            activeMetadata = metadata
            lastCallbackNanoseconds = nil
            metrics.cropConfiguration.record(configurationNanoseconds)
        }
    }

    func deactivateAndClear(generation: UInt64) {
        queue.sync {
            guard activeGeneration == generation else { return }
            activeGeneration = nil
            activeMetadata = nil
            do {
                _ = try client.sendClearIfNeeded()
            } catch {
                markFatal(error)
            }
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
        metrics.callbackCount += 1
        let isPostWarmup = metrics.completeFrameCount >= metricWarmupCompleteFrames
        metrics.firstCallbackNanoseconds = metrics.firstCallbackNanoseconds ?? callbackStart
        metrics.lastCallbackNanoseconds = callbackStart
        if isPostWarmup, let lastCallbackNanoseconds {
            metrics.callbackInterval.record(callbackStart - lastCallbackNanoseconds)
        }
        lastCallbackNanoseconds = callbackStart

        guard activeGeneration == generation,
              let metadata = activeMetadata,
              metadata.generation == generation else {
            metrics.callbacksRejectedAfterAuthorityLoss += 1
            return
        }

        guard let status = frameStatus(sampleBuffer) else {
            metrics.incompleteFrameCount += 1
            return
        }
        guard status == .complete else {
            metrics.incompleteFrameCount += 1
            switch status {
            case .idle: metrics.idleFrameCount += 1
            case .blank: metrics.blankFrameCount += 1
            case .suspended: metrics.suspendedFrameCount += 1
            case .started: metrics.startedFrameCount += 1
            case .stopped: metrics.stoppedFrameCount += 1
            default: break
            }
            return
        }

        guard let pixelBuffer = sampleBuffer.imageBuffer else {
            metrics.invalidPixelBufferCount += 1
            return
        }
        if isPostWarmup {
            metrics.statusAcceptance.record(DispatchTime.now().uptimeNanoseconds - callbackStart)
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
        guard width == destination.width, height == destination.height,
              bytesPerRow >= destination.stride else {
            metrics.rowStrideMismatches += 1
            return
        }

        let accessStart = DispatchTime.now().uptimeNanoseconds
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess,
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            metrics.invalidPixelBufferCount += 1
            return
        }
        let accessEnd = DispatchTime.now().uptimeNanoseconds
        if isPostWarmup {
            metrics.pixelBufferAccess.record(accessEnd - accessStart)
        }

        let shouldHashFirstFrame = metrics.firstCroppedSHA256 == nil
        var sourceHasher = SHA256()
        let copyStart = accessEnd
        outputBuffer.withUnsafeMutableBytes { destinationBytes in
            for row in 0 ..< destination.height {
                let sourceRow = baseAddress.advanced(by: row * bytesPerRow)
                let destinationRow = destinationBytes.baseAddress!.advanced(by: row * destination.stride)
                if shouldHashFirstFrame {
                    sourceHasher.update(
                        bufferPointer: UnsafeRawBufferPointer(
                            start: sourceRow,
                            count: destination.stride
                        )
                    )
                }
                memcpy(destinationRow, sourceRow, destination.stride)
                let rowBytes = destinationBytes.bindMemory(to: UInt8.self)
                let rowStart = row * destination.stride
                let rowEnd = rowStart + destination.stride
                var alpha = rowStart + 3
                while alpha < rowEnd {
                    rowBytes[alpha] = 0xFF
                    alpha += 4
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        var alphaMismatch = false
        outputBuffer.withUnsafeBytes { bytes in
            let pixels = bytes.bindMemory(to: UInt8.self)
            var alpha = 3
            while alpha < pixels.count {
                if pixels[alpha] != 0xFF {
                    alphaMismatch = true
                    break
                }
                alpha += 4
            }
        }
        if alphaMismatch {
            metrics.outputAlphaMismatches += 1
            return
        }
        let copyEnd = DispatchTime.now().uptimeNanoseconds
        if isPostWarmup {
            metrics.copyAndNormalize.record(copyEnd - copyStart)
        }

        do {
            let timing = try client.sendFrame(destination: destination, pixels: outputBuffer)
            let sendEnd = DispatchTime.now().uptimeNanoseconds
            guard activeGeneration == generation else {
                metrics.framesPublishedAfterAuthorityLoss += 1
                return
            }
            metrics.completeFrameCount += 1
            if isPostWarmup {
                metrics.protocolHeader.record(timing.headerPreparationNanoseconds)
                metrics.socketSend.record(timing.socketSendNanoseconds)
                metrics.sampleToSend.record(sendEnd - callbackStart)
            }
            if shouldHashFirstFrame {
                metrics.firstCroppedSHA256 = sourceHasher.finalize().map {
                    String(format: "%02x", $0)
                }.joined()
                metrics.firstOutputSHA256 = SHA256.hash(data: outputBuffer).map {
                    String(format: "%02x", $0)
                }.joined()
            }
        } catch {
            metrics.protocolSendFailures += 1
            markFatal(error)
        }
    }

    func shutdown() -> String {
        queue.sync {
            activeGeneration = nil
            activeMetadata = nil
            do {
                _ = try client.sendClearIfNeeded()
            } catch {
                markFatal(error)
            }
            let snapshot = client.snapshot()
            let output = metrics.output(protocolSnapshot: snapshot, finalBuffer: outputBuffer)
            client.close()
            _ = outputBuffer.withUnsafeMutableBytes { bytes in
                bytes.initializeMemory(as: UInt8.self, repeating: 0)
            }
            return output
        }
    }

    private func frameStatus(_ sampleBuffer: CMSampleBuffer) -> SCFrameStatus? {
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(
            sampleBuffer,
            createIfNecessary: false
        ) as? [[SCStreamFrameInfo: Any]],
        let first = attachments.first,
        let rawValue = first[.status] as? Int else {
            return nil
        }
        return SCFrameStatus(rawValue: rawValue)
    }

    private func markFatal(_ error: Error) {
        if fatalErrorDescription == nil {
            fatalErrorDescription = error.localizedDescription
        }
    }
}

final class CaptureSampleOutput: NSObject, SCStreamOutput {
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

struct CaptureSignature: Equatable {
    let windowID: CGWindowID
    let widthMilliPoints: Int
    let heightMilliPoints: Int

    init(candidate: WindowCandidate) {
        windowID = candidate.windowID
        widthMilliPoints = Int((candidate.frame.width * 1_000).rounded())
        heightMilliPoints = Int((candidate.frame.height * 1_000).rounded())
    }
}

final class WindowCapture: NSObject, SCStreamDelegate {
    let signature: CaptureSignature
    let metadata: CaptureSourceMetadata

    private var stream: SCStream!
    private var sampleOutput: CaptureSampleOutput!
    private let outputCoordinator: CaptureOutputCoordinator
    private let failureLock = NSLock()
    private var failureMessage: String?
    private var started = false

    init(
        candidate: WindowCandidate,
        configuration: CaptureConfiguration,
        generation: UInt64,
        outputCoordinator: CaptureOutputCoordinator
    ) throws {
        guard let window = candidate.window,
              let crop = configuration.normalizedCrop,
              let destination = configuration.destination else {
            throw CaptureConfigurationError.invalid("selected window cannot be captured")
        }

        let configurationStart = DispatchTime.now().uptimeNanoseconds
        let filter = SCContentFilter(desktopIndependentWindow: window)
        let contentRect = filter.contentRect
        let sourceRect = try crop.sourceRect(in: contentRect)

        let streamConfiguration = SCStreamConfiguration()
        streamConfiguration.width = destination.width
        streamConfiguration.height = destination.height
        streamConfiguration.minimumFrameInterval = CMTime(
            value: 1,
            timescale: CMTimeScale(configuration.fps)
        )
        streamConfiguration.pixelFormat = kCVPixelFormatType_32BGRA
        streamConfiguration.scalesToFit = true
        streamConfiguration.preservesAspectRatio = false
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
        streamConfiguration.ignoreShadowsSingleWindow = true
        streamConfiguration.shouldBeOpaque = true
        streamConfiguration.ignoreGlobalClipSingleWindow = true
        if #available(macOS 14.2, *) {
            streamConfiguration.includeChildWindows = false
        }

        signature = CaptureSignature(candidate: candidate)
        metadata = CaptureSourceMetadata(
            windowID: candidate.windowID,
            generation: generation,
            windowFrame: candidate.frame,
            filterContentRect: contentRect,
            normalizedCrop: crop,
            sourceRect: sourceRect,
            pointPixelScale: filter.pointPixelScale,
            destination: destination
        )
        self.outputCoordinator = outputCoordinator
        super.init()
        sampleOutput = CaptureSampleOutput(coordinator: outputCoordinator, generation: generation)
        stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
        try stream.addStreamOutput(
            sampleOutput,
            type: .screen,
            sampleHandlerQueue: outputCoordinator.queue
        )
        let configurationEnd = DispatchTime.now().uptimeNanoseconds
        outputCoordinator.activate(
            metadata: metadata,
            configurationNanoseconds: configurationEnd - configurationStart
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
                // Authority is already revoked; retain the bounded stop error locally.
                failureLock.withLock { failureMessage = failureMessage ?? error.localizedDescription }
            }
            started = false
        }
        do {
            try stream.removeStreamOutput(sampleOutput, type: .screen)
        } catch {
            failureLock.withLock { failureMessage = failureMessage ?? error.localizedDescription }
        }
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        failureLock.withLock { failureMessage = error.localizedDescription }
        outputCoordinator.recordStreamFailure()
    }

    func captureFailure() -> String? {
        failureLock.withLock { failureMessage }
    }
}
