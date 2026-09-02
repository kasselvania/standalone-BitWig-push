// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation

enum CaptureConfigurationError: LocalizedError {
    case helpRequested
    case invalid(String)

    var errorDescription: String? {
        switch self {
        case .helpRequested:
            return nil
        case let .invalid(message):
            return message
        }
    }
}

enum SourceRole: String {
    case nativeDevice = "native-device"
    case plugin
}

struct NormalizedCrop: Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(x: Double, y: Double, width: Double, height: Double) throws {
        let values = [x, y, width, height]
        guard values.allSatisfy(\.isFinite), x >= 0, y >= 0,
              width > 0, height > 0, x <= 1, y <= 1,
              x + width <= 1, y + height <= 1 else {
            throw CaptureConfigurationError.invalid(
                "normalized crop must be finite, positive, and wholly inside [0,1]"
            )
        }
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    func sourceRect(in contentRect: CGRect) throws -> CGRect {
        guard contentRect.width > 0, contentRect.height > 0,
              contentRect.origin.x.isFinite, contentRect.origin.y.isFinite,
              contentRect.width.isFinite, contentRect.height.isFinite else {
            throw CaptureConfigurationError.invalid("capture filter has invalid content bounds")
        }

        let result = CGRect(
            x: contentRect.minX + x * contentRect.width,
            y: contentRect.minY + y * contentRect.height,
            width: width * contentRect.width,
            height: height * contentRect.height
        )
        guard result.width > 0, result.height > 0,
              contentRect.contains(result) else {
            throw CaptureConfigurationError.invalid("computed source crop is outside the window")
        }
        return result
    }
}

struct PushDestination: Equatable {
    static let frameWidth = 960
    static let frameHeight = 160
    static let maximumPayloadBytes = frameWidth * frameHeight * 4

    let x: Int
    let y: Int
    let width: Int
    let height: Int

    init(x: Int, y: Int, width: Int, height: Int) throws {
        guard x >= 0, y >= 0, width > 0, height > 0,
              x <= Self.frameWidth, y <= Self.frameHeight,
              width <= Self.frameWidth - x,
              height <= Self.frameHeight - y,
              width <= Self.maximumPayloadBytes / 4 / height else {
            throw CaptureConfigurationError.invalid("destination must fit inside the 960x160 Push frame")
        }
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    var stride: Int { width * 4 }
    var payloadBytes: Int { stride * height }
}

struct CaptureConfiguration {
    static let expectedBundleIdentifier = "com.kasselvania.pushwig.capture-helper"
    static let defaultPort = 45_291
    static let defaultFPS = 30
    static let discoveryPollNanoseconds: UInt64 = 500_000_000
    static let streamQueueDepth = 2

    let listWindows: Bool
    let ownerBundleIdentifier: String?
    let exactTitle: String?
    let role: SourceRole?
    let normalizedCrop: NormalizedCrop?
    let destination: PushDestination?
    let fps: Int
    let port: Int
    let tokenFile: URL?

    static func parse(arguments: [String]) throws -> CaptureConfiguration {
        var values: [String: String] = [:]
        var flags = Set<String>()
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--help", "-h", "--list-windows":
                guard flags.insert(argument).inserted else {
                    throw CaptureConfigurationError.invalid("duplicate option: \(argument)")
                }
                index += 1
            case "--owner-bundle-id", "--title-exact", "--role",
                 "--crop-normalized", "--destination", "--fps", "--port", "--token-file":
                guard values[argument] == nil else {
                    throw CaptureConfigurationError.invalid("duplicate option: \(argument)")
                }
                guard index + 1 < arguments.count else {
                    throw CaptureConfigurationError.invalid("missing value for \(argument)")
                }
                values[argument] = arguments[index + 1]
                index += 2
            default:
                throw CaptureConfigurationError.invalid("unknown option: \(argument)")
            }
        }

        if flags.contains("--help") || flags.contains("-h") {
            throw CaptureConfigurationError.helpRequested
        }

        let listWindows = flags.contains("--list-windows")
        let owner = nonblank(values["--owner-bundle-id"])
        let title = nonblank(values["--title-exact"])
        let role = values["--role"].flatMap(SourceRole.init(rawValue:))
        let fps = try parseBoundedInteger(values["--fps"], defaultValue: defaultFPS,
                                          range: 1 ... 60, label: "fps")
        let port = try parseBoundedInteger(values["--port"], defaultValue: defaultPort,
                                           range: 1_024 ... 65_535, label: "port")

        if listWindows {
            return CaptureConfiguration(
                listWindows: true,
                ownerBundleIdentifier: owner,
                exactTitle: title,
                role: role,
                normalizedCrop: nil,
                destination: nil,
                fps: fps,
                port: port,
                tokenFile: nil
            )
        }

        guard let owner else {
            throw CaptureConfigurationError.invalid("--owner-bundle-id is required")
        }
        guard let title else {
            throw CaptureConfigurationError.invalid("--title-exact is required")
        }
        guard let role else {
            throw CaptureConfigurationError.invalid("--role must be native-device or plugin")
        }
        guard let cropText = values["--crop-normalized"] else {
            throw CaptureConfigurationError.invalid("--crop-normalized x,y,width,height is required")
        }
        guard let destinationText = values["--destination"] else {
            throw CaptureConfigurationError.invalid("--destination x,y,width,height is required")
        }
        guard let tokenText = nonblank(values["--token-file"]) else {
            throw CaptureConfigurationError.invalid("--token-file is required")
        }

        return CaptureConfiguration(
            listWindows: false,
            ownerBundleIdentifier: owner,
            exactTitle: title,
            role: role,
            normalizedCrop: try parseCrop(cropText),
            destination: try parseDestination(destinationText),
            fps: fps,
            port: port,
            tokenFile: URL(fileURLWithPath: tokenText).standardizedFileURL
        )
    }

    static var usage: String {
        """
        usage:
          PushwigCaptureHelper --list-windows [--owner-bundle-id ID] [--title-exact TITLE]
          PushwigCaptureHelper --owner-bundle-id ID --title-exact TITLE \\
            --role native-device|plugin --crop-normalized x,y,w,h \\
            --destination x,y,w,h --token-file PATH [--port PORT] [--fps 1...60]
        """
    }

    private static func nonblank(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }

    private static func parseBoundedInteger(
        _ value: String?, defaultValue: Int, range: ClosedRange<Int>, label: String
    ) throws -> Int {
        guard let value else { return defaultValue }
        guard let parsed = Int(value), range.contains(parsed) else {
            throw CaptureConfigurationError.invalid("\(label) must be in \(range)")
        }
        return parsed
    }

    private static func commaSeparated(_ text: String, label: String) throws -> [String] {
        let parts = text.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 4 else {
            throw CaptureConfigurationError.invalid("\(label) requires four comma-separated values")
        }
        return parts
    }

    private static func parseCrop(_ text: String) throws -> NormalizedCrop {
        let parts = try commaSeparated(text, label: "crop")
        guard let x = Double(parts[0]), let y = Double(parts[1]),
              let width = Double(parts[2]), let height = Double(parts[3]) else {
            throw CaptureConfigurationError.invalid("crop values must be finite numbers")
        }
        return try NormalizedCrop(x: x, y: y, width: width, height: height)
    }

    private static func parseDestination(_ text: String) throws -> PushDestination {
        let parts = try commaSeparated(text, label: "destination")
        guard let x = Int(parts[0]), let y = Int(parts[1]),
              let width = Int(parts[2]), let height = Int(parts[3]) else {
            throw CaptureConfigurationError.invalid("destination values must be integers")
        }
        return try PushDestination(x: x, y: y, width: width, height: height)
    }
}
