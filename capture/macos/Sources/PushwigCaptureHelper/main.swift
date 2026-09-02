// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AppKit
import CoreGraphics
import Darwin
import Foundation

private enum SourceState: String {
    case noSource = "NO_SOURCE"
    case uniqueSource = "UNIQUE_SOURCE"
    case capturing = "CAPTURING"
    case ambiguous = "AMBIGUOUS"
    case permissionDenied = "PERMISSION_DENIED"
    case captureFailed = "CAPTURE_FAILED"
}

private enum CaptureApplicationError: LocalizedError {
    case wrongBundleIdentity(String?)
    case permissionDenied
    case outputFailed(String)

    var errorDescription: String? {
        switch self {
        case let .wrongBundleIdentity(actual):
            return "run the packaged PushwigCaptureHelper.app; bundle identity was \(actual ?? "absent")"
        case .permissionDenied:
            return "Screen Recording permission is required; enable Pushwig Capture Helper in System Settings > Privacy & Security > Screen & System Audio Recording, then relaunch this same app build"
        case let .outputFailed(message):
            return "external raster output failed: \(message)"
        }
    }
}

@MainActor
private final class CaptureApplication {
    private let configuration: CaptureConfiguration
    private let descriptor: WindowDescriptor
    private let outputCoordinator: CaptureOutputCoordinator
    private var currentCapture: WindowCapture?
    private var currentState: SourceState?
    private var failedSignature: CaptureSignature?
    private var nextGeneration: UInt64 = 1
    private var stopRequested = false
    private var wrongWindowSelections: UInt64 = 0
    private var ambiguityAbstentions: UInt64 = 0
    private var missingAbstentions: UInt64 = 0
    private var reacquisitions: UInt64 = 0

    init(configuration: CaptureConfiguration) throws {
        guard let owner = configuration.ownerBundleIdentifier,
              let title = configuration.exactTitle,
              let role = configuration.role,
              let destination = configuration.destination,
              let tokenFile = configuration.tokenFile else {
            throw CaptureConfigurationError.invalid("capture configuration is incomplete")
        }
        self.configuration = configuration
        descriptor = WindowDescriptor(
            ownerBundleIdentifier: owner,
            exactTitle: title,
            role: role
        )
        let client = try ExternalRasterProtocolClient(port: configuration.port, tokenFile: tokenFile)
        outputCoordinator = CaptureOutputCoordinator(client: client, destination: destination)
    }

    func requestStop() {
        stopRequested = true
    }

    func run() async throws {
        do {
            while !stopRequested {
                if let failure = outputCoordinator.failureDescription() {
                    throw CaptureApplicationError.outputFailed(failure)
                }
                if !CGPreflightScreenCaptureAccess() {
                    transition(to: .permissionDenied, detail: "runtime permission unavailable")
                    throw CaptureApplicationError.permissionDenied
                }
                try await pollOnce()
                try await Task.sleep(nanoseconds: CaptureConfiguration.discoveryPollNanoseconds)
            }
            await finish()
        } catch {
            await finish()
            throw error
        }
    }

    private func pollOnce() async throws {
        let candidates: [WindowCandidate]
        do {
            candidates = try await WindowDiscovery.currentCandidates()
        } catch {
            transition(to: .captureFailed, detail: "shareable content unavailable")
            await stopCurrentCapture()
            return
        }

        switch WindowDiscovery.resolve(candidates: candidates, descriptor: descriptor) {
        case .missing:
            missingAbstentions += 1
            failedSignature = nil
            transition(to: .noSource, detail: "matches=0")
            await stopCurrentCapture()
        case let .ambiguous(matches):
            ambiguityAbstentions += 1
            failedSignature = nil
            transition(to: .ambiguous, detail: "matches=\(matches.count)")
            await stopCurrentCapture()
        case let .unique(candidate):
            guard candidate.ownerBundleIdentifier == descriptor.ownerBundleIdentifier,
                  candidate.title == descriptor.exactTitle else {
                wrongWindowSelections += 1
                transition(to: .captureFailed, detail: "resolver identity mismatch")
                await stopCurrentCapture()
                return
            }
            let signature = CaptureSignature(candidate: candidate)
            if failedSignature == signature {
                transition(to: .captureFailed, detail: "waiting for source replacement")
                return
            }
            if let currentCapture, currentCapture.signature == signature {
                if let failure = currentCapture.captureFailure() {
                    failedSignature = signature
                    transition(to: .captureFailed, detail: "stream stopped: \(bounded(failure))")
                    await stopCurrentCapture()
                }
                return
            }

            let wasPreviouslyCaptured = currentCapture != nil || currentState == .noSource
            transition(to: .uniqueSource, detail: "window_id=\(candidate.windowID)")
            await stopCurrentCapture()
            let generation = nextGeneration
            nextGeneration &+= 1
            if nextGeneration == 0 { nextGeneration = 1 }
            do {
                let capture = try WindowCapture(
                    candidate: candidate,
                    configuration: configuration,
                    generation: generation,
                    outputCoordinator: outputCoordinator
                )
                currentCapture = capture
                try await capture.start()
                if wasPreviouslyCaptured { reacquisitions += 1 }
                let metadata = capture.metadata
                transition(
                    to: .capturing,
                    detail: "window_id=\(metadata.windowID) "
                        + "window_frame=\(WindowDiscovery.format(metadata.windowFrame)) "
                        + "content_rect=\(WindowDiscovery.format(metadata.filterContentRect)) "
                        + "source_rect=\(WindowDiscovery.format(metadata.sourceRect)) "
                        + "normalized_crop=\(normalized(metadata.normalizedCrop)) "
                        + "destination=\(destination(metadata.destination)) "
                        + String(format: "point_pixel_scale=%.3f", metadata.pointPixelScale)
                )
            } catch {
                failedSignature = signature
                transition(to: .captureFailed, detail: bounded(error.localizedDescription))
                await stopCurrentCapture()
            }
        }
    }

    private func stopCurrentCapture() async {
        guard let capture = currentCapture else { return }
        currentCapture = nil
        await capture.stop()
    }

    private func finish() async {
        await stopCurrentCapture()
        let metrics = outputCoordinator.shutdown()
        print(metrics)
        print(
            "DISCOVERY wrong_window_selections=\(wrongWindowSelections) "
                + "ambiguity_abstentions=\(ambiguityAbstentions) "
                + "missing_abstentions=\(missingAbstentions) reacquisitions=\(reacquisitions)"
        )
    }

    private func transition(to state: SourceState, detail: String) {
        guard currentState != state || state == .capturing else { return }
        currentState = state
        print("STATE role=\(descriptor.role.rawValue) value=\(state.rawValue) \(detail)")
    }

    private func bounded(_ message: String) -> String {
        let singleLine = message.replacingOccurrences(of: "\n", with: " ")
        return String(singleLine.prefix(240))
    }

    private func normalized(_ crop: NormalizedCrop) -> String {
        String(format: "%.6f,%.6f,%.6f,%.6f", crop.x, crop.y, crop.width, crop.height)
    }

    private func destination(_ value: PushDestination) -> String {
        "\(value.x),\(value.y),\(value.width),\(value.height)"
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
        _ = NSApplication.shared.setActivationPolicy(.accessory)

        let configuration: CaptureConfiguration
        do {
            configuration = try CaptureConfiguration.parse(
                arguments: Array(CommandLine.arguments.dropFirst())
            )
        } catch CaptureConfigurationError.helpRequested {
            print(CaptureConfiguration.usage)
            return 0
        } catch {
            fputs("error: \(error.localizedDescription)\n\(CaptureConfiguration.usage)\n", stderr)
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

        guard ensureScreenRecordingPermission() else {
            fputs("error: \(CaptureApplicationError.permissionDenied.localizedDescription)\n", stderr)
            return 77
        }

        if configuration.listWindows {
            do {
                let candidates = try await WindowDiscovery.currentCandidates()
                WindowDiscovery.printInventory(
                    candidates: candidates,
                    ownerFilter: configuration.ownerBundleIdentifier,
                    titleFilter: configuration.exactTitle
                )
            } catch {
                fputs("error: window inventory failed: \(error.localizedDescription)\n", stderr)
                return 70
            }
            return 0
        }

        do {
            let application = try CaptureApplication(configuration: configuration)
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

private func ensureScreenRecordingPermission() -> Bool {
        if CGPreflightScreenCaptureAccess() {
            print("PERMISSION preflight=granted")
            return true
        }
        let granted = CGRequestScreenCaptureAccess()
        print("PERMISSION preflight=denied request=\(granted ? "granted" : "denied")")
        return granted && CGPreflightScreenCaptureAccess()
}

Task { @MainActor in
    exit(await runMain())
}
dispatchMain()
