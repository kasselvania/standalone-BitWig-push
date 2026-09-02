// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import Foundation

enum CaptureConfigurationError: LocalizedError, Equatable {
  case helpRequested
  case invalid(String)

  var errorDescription: String? {
    switch self {
    case .helpRequested:
      return nil
    case .invalid(let message):
      return message
    }
  }
}

struct NormalizedCrop: Equatable {
  let x: Double
  let y: Double
  let width: Double
  let height: Double

  init(x: Double, y: Double, width: Double, height: Double) throws {
    guard x.isFinite, y.isFinite, width.isFinite, height.isFinite,
      x >= 0, x < 1, y >= 0, y < 1,
      width > 0, width <= 1, height > 0, height <= 1,
      width <= 1 - x, height <= 1 - y
    else {
      throw CaptureConfigurationError.invalid(
        "normalized crop must be finite, positive, and wholly inside [0,1]"
      )
    }
    self.x = x
    self.y = y
    self.width = width
    self.height = height
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
    guard x >= 0, x < Self.frameWidth,
      y >= 0, y < Self.frameHeight,
      width > 0, width <= Self.frameWidth - x,
      height > 0, height <= Self.frameHeight - y,
      width <= Self.maximumPayloadBytes / 4 / height
    else {
      throw CaptureConfigurationError.invalid(
        "destination must be positive and wholly inside the 960x160 Push frame"
      )
    }
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }

  var stride: Int { width * 4 }
  var payloadBytes: Int { stride * height }
}

struct CaptureConfiguration: Equatable {
  static let expectedBundleIdentifier = "com.kasselvania.pushwig.capture-helper"
  static let streamQueueDepth = 2
  static let guardPollNanoseconds: UInt64 = 100_000_000
  static let displayRevalidationPollInterval: UInt64 = 5
  static let permissionRevalidationPollInterval: UInt64 = 50

  let listDisplays: Bool
  let displayID: UInt32?
  let expectedDisplayWidth: Int?
  let expectedDisplayHeight: Int?
  let normalizedCrop: NormalizedCrop?
  let destination: PushDestination?
  let fps: Int?
  let port: Int?
  let tokenFile: URL?
  let requiredFrontmostBundleIdentifier: String?

  static func parse(arguments: [String]) throws -> CaptureConfiguration {
    var values: [String: String] = [:]
    var flags = Set<String>()
    var index = 0

    while index < arguments.count {
      let argument = arguments[index]
      switch argument {
      case "--help", "-h", "--list-displays":
        guard flags.insert(argument).inserted else {
          throw CaptureConfigurationError.invalid("duplicate option: \(argument)")
        }
        index += 1
      case "--display-id", "--expected-display-width", "--expected-display-height",
        "--crop-normalized", "--destination", "--fps", "--port", "--token-file",
        "--required-frontmost-bundle-id":
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

    if flags.contains("--list-displays") {
      guard values.isEmpty, flags.count == 1 else {
        throw CaptureConfigurationError.invalid(
          "--list-displays cannot be combined with capture options"
        )
      }
      return CaptureConfiguration(
        listDisplays: true,
        displayID: nil,
        expectedDisplayWidth: nil,
        expectedDisplayHeight: nil,
        normalizedCrop: nil,
        destination: nil,
        fps: nil,
        port: nil,
        tokenFile: nil,
        requiredFrontmostBundleIdentifier: nil
      )
    }

    guard flags.isEmpty else {
      throw CaptureConfigurationError.invalid("unsupported flag combination")
    }

    let displayID = try requiredUInt32(values["--display-id"], label: "display ID")
    let expectedWidth = try requiredInteger(
      values["--expected-display-width"], range: 1...65_535,
      label: "expected display width"
    )
    let expectedHeight = try requiredInteger(
      values["--expected-display-height"], range: 1...65_535,
      label: "expected display height"
    )
    let fps = try requiredInteger(values["--fps"], range: 1...60, label: "fps")
    let port = try requiredInteger(values["--port"], range: 1_024...65_535, label: "port")

    guard let cropText = values["--crop-normalized"] else {
      throw CaptureConfigurationError.invalid(
        "--crop-normalized x,y,width,height is required"
      )
    }
    guard let destinationText = values["--destination"] else {
      throw CaptureConfigurationError.invalid("--destination x,y,width,height is required")
    }
    guard let tokenText = nonblank(values["--token-file"]) else {
      throw CaptureConfigurationError.invalid("--token-file is required")
    }
    guard let guardBundleID = nonblank(values["--required-frontmost-bundle-id"]),
      isBundleIdentifier(guardBundleID)
    else {
      throw CaptureConfigurationError.invalid(
        "--required-frontmost-bundle-id must be a valid explicit bundle identifier"
      )
    }

    return CaptureConfiguration(
      listDisplays: false,
      displayID: displayID,
      expectedDisplayWidth: expectedWidth,
      expectedDisplayHeight: expectedHeight,
      normalizedCrop: try parseCrop(cropText),
      destination: try parseDestination(destinationText),
      fps: fps,
      port: port,
      tokenFile: URL(fileURLWithPath: tokenText).standardizedFileURL,
      requiredFrontmostBundleIdentifier: guardBundleID
    )
  }

  static var usage: String {
    """
    usage:
      PushwigCaptureHelper --list-displays
      PushwigCaptureHelper --display-id ID \\
        --expected-display-width POINTS --expected-display-height POINTS \\
        --crop-normalized x,y,width,height --destination x,y,width,height \\
        --fps 1...60 --port 1024...65535 --token-file PATH \\
        --required-frontmost-bundle-id ID
    """
  }

  private static func nonblank(_ value: String?) -> String? {
    guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return nil
    }
    return value
  }

  private static func requiredInteger(
    _ value: String?, range: ClosedRange<Int>, label: String
  ) throws -> Int {
    guard let value, let parsed = Int(value), range.contains(parsed) else {
      throw CaptureConfigurationError.invalid("\(label) must be in \(range)")
    }
    return parsed
  }

  private static func requiredUInt32(_ value: String?, label: String) throws -> UInt32 {
    guard let value, let parsed = UInt32(value), parsed > 0 else {
      throw CaptureConfigurationError.invalid("\(label) must be a positive UInt32")
    }
    return parsed
  }

  private static func commaSeparated(_ text: String, label: String) throws -> [String] {
    let parts = text.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
    guard parts.count == 4 else {
      throw CaptureConfigurationError.invalid(
        "\(label) requires four comma-separated values"
      )
    }
    return parts
  }

  private static func parseCrop(_ text: String) throws -> NormalizedCrop {
    let parts = try commaSeparated(text, label: "crop")
    guard let x = Double(parts[0]), let y = Double(parts[1]),
      let width = Double(parts[2]), let height = Double(parts[3])
    else {
      throw CaptureConfigurationError.invalid("crop values must be floating-point numbers")
    }
    return try NormalizedCrop(x: x, y: y, width: width, height: height)
  }

  private static func parseDestination(_ text: String) throws -> PushDestination {
    let parts = try commaSeparated(text, label: "destination")
    guard let x = Int(parts[0]), let y = Int(parts[1]),
      let width = Int(parts[2]), let height = Int(parts[3])
    else {
      throw CaptureConfigurationError.invalid("destination values must be integers")
    }
    return try PushDestination(x: x, y: y, width: width, height: height)
  }

  private static func isBundleIdentifier(_ value: String) -> Bool {
    let parts = value.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count >= 2 else { return false }
    return parts.allSatisfy { part in
      !part.isEmpty
        && part.utf8.allSatisfy {
          ($0 >= 48 && $0 <= 57) || ($0 >= 65 && $0 <= 90)
            || ($0 >= 97 && $0 <= 122) || $0 == 45
        }
    }
  }
}
