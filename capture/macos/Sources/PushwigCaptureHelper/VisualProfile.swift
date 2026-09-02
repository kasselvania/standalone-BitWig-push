// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import Foundation

struct VisualProfile: Equatable {
  static let schemaVersion = 1
  static let maximumFileBytes = 65_536

  struct WindowSelector: Equatable {
    let ownerBundleIdentifier: String
    let titleContains: String?
    let minimumWidthPoints: Double
    let minimumHeightPoints: Double
  }

  let id: String
  let window: WindowSelector
  let crop: NormalizedCrop
  let destination: PushDestination
  let fps: Int
  let aspectPolicy: AspectMapping.Policy

  static func load(from url: URL) throws -> VisualProfile {
    let handle: FileHandle
    do {
      handle = try FileHandle(forReadingFrom: url)
    } catch {
      throw CaptureConfigurationError.invalid(
        "profile cannot be opened: \(error.localizedDescription)"
      )
    }
    defer { try? handle.close() }

    let data: Data
    do {
      data = try handle.read(upToCount: maximumFileBytes + 1) ?? Data()
    } catch {
      throw CaptureConfigurationError.invalid(
        "profile cannot be read: \(error.localizedDescription)"
      )
    }
    guard !data.isEmpty, data.count <= maximumFileBytes else {
      throw CaptureConfigurationError.invalid(
        "profile must contain 1...\(maximumFileBytes) bytes"
      )
    }
    return try decode(data)
  }

  static func decode(_ data: Data) throws -> VisualProfile {
    let object: Any
    do {
      object = try JSONSerialization.jsonObject(with: data)
    } catch {
      throw CaptureConfigurationError.invalid(
        "profile is not valid JSON: \(error.localizedDescription)"
      )
    }

    try rejectUnknownKeys(
      in: object,
      allowed: ["schemaVersion", "id", "window", "crop", "destination", "fps", "aspectPolicy"],
      context: "profile"
    )
    guard let root = object as? [String: Any] else {
      throw CaptureConfigurationError.invalid("profile root must be a JSON object")
    }
    try rejectUnknownKeys(
      in: root["window"],
      allowed: [
        "ownerBundleIdentifier", "titleContains", "minimumWidthPoints", "minimumHeightPoints",
      ],
      context: "profile.window"
    )
    try rejectUnknownKeys(
      in: root["crop"],
      allowed: ["x", "y", "width", "height"],
      context: "profile.crop"
    )
    try rejectUnknownKeys(
      in: root["destination"],
      allowed: ["x", "y", "width", "height"],
      context: "profile.destination"
    )

    let decoded: ProfileDocument
    do {
      decoded = try JSONDecoder().decode(ProfileDocument.self, from: data)
    } catch {
      throw CaptureConfigurationError.invalid(
        "profile schema is malformed: \(error.localizedDescription)"
      )
    }

    guard decoded.schemaVersion == schemaVersion else {
      throw CaptureConfigurationError.invalid(
        "unsupported profile schemaVersion \(decoded.schemaVersion); expected \(schemaVersion)"
      )
    }
    let id = decoded.id.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !id.isEmpty else {
      throw CaptureConfigurationError.invalid("profile id must not be blank")
    }
    let owner = decoded.window.ownerBundleIdentifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard owner == decoded.window.ownerBundleIdentifier,
      CaptureConfiguration.isBundleIdentifier(owner)
    else {
      throw CaptureConfigurationError.invalid(
        "profile window ownerBundleIdentifier must be a valid bundle identifier"
      )
    }
    let titleContains: String?
    if let rawTitle = decoded.window.titleContains {
      let trimmed = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        throw CaptureConfigurationError.invalid(
          "profile window titleContains must be null or nonblank"
        )
      }
      titleContains = trimmed
    } else {
      titleContains = nil
    }
    guard decoded.window.minimumWidthPoints.isFinite,
      decoded.window.minimumHeightPoints.isFinite,
      decoded.window.minimumWidthPoints > 0,
      decoded.window.minimumHeightPoints > 0,
      decoded.window.minimumWidthPoints <= 65_535,
      decoded.window.minimumHeightPoints <= 65_535
    else {
      throw CaptureConfigurationError.invalid(
        "profile minimum window dimensions must be finite and in (0,65535] points"
      )
    }
    guard (1...60).contains(decoded.fps) else {
      throw CaptureConfigurationError.invalid("profile fps must be in 1...60")
    }
    guard let aspectPolicy = AspectMapping.Policy(rawValue: decoded.aspectPolicy) else {
      throw CaptureConfigurationError.invalid(
        "profile aspectPolicy must be centered-cover"
      )
    }

    return VisualProfile(
      id: id,
      window: WindowSelector(
        ownerBundleIdentifier: owner,
        titleContains: titleContains,
        minimumWidthPoints: decoded.window.minimumWidthPoints,
        minimumHeightPoints: decoded.window.minimumHeightPoints
      ),
      crop: try NormalizedCrop(
        x: decoded.crop.x,
        y: decoded.crop.y,
        width: decoded.crop.width,
        height: decoded.crop.height
      ),
      destination: try PushDestination(
        x: decoded.destination.x,
        y: decoded.destination.y,
        width: decoded.destination.width,
        height: decoded.destination.height
      ),
      fps: decoded.fps,
      aspectPolicy: aspectPolicy
    )
  }

  private static func rejectUnknownKeys(
    in object: Any?,
    allowed: Set<String>,
    context: String
  ) throws {
    guard let dictionary = object as? [String: Any] else {
      throw CaptureConfigurationError.invalid("\(context) must be a JSON object")
    }
    let unknown = Set(dictionary.keys).subtracting(allowed).sorted()
    guard unknown.isEmpty else {
      throw CaptureConfigurationError.invalid(
        "\(context) contains unknown key(s): \(unknown.joined(separator: ", "))"
      )
    }
  }
}

private struct ProfileDocument: Decodable {
  struct Window: Decodable {
    let ownerBundleIdentifier: String
    let titleContains: String?
    let minimumWidthPoints: Double
    let minimumHeightPoints: Double
  }

  struct Crop: Decodable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
  }

  struct Destination: Decodable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
  }

  let schemaVersion: Int
  let id: String
  let window: Window
  let crop: Crop
  let destination: Destination
  let fps: Int
  let aspectPolicy: String
}
