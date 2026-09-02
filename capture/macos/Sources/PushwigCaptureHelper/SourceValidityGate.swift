// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AppKit
import Foundation

struct SourceValiditySnapshot: Equatable {
  let frontmostBundleIdentifier: String?
  let runningBundleIdentifiers: Set<String>
}

struct SourceValidityDecision: Equatable {
  let isValid: Bool
  let reason: String
}

enum SourceValidityGate {
  static func evaluate(
    requiredBundleIdentifier: String,
    snapshot: SourceValiditySnapshot
  ) -> SourceValidityDecision {
    guard snapshot.runningBundleIdentifiers.contains(requiredBundleIdentifier) else {
      return SourceValidityDecision(isValid: false, reason: "required-application-not-running")
    }
    guard snapshot.frontmostBundleIdentifier == requiredBundleIdentifier else {
      return SourceValidityDecision(isValid: false, reason: "required-application-not-frontmost")
    }
    return SourceValidityDecision(isValid: true, reason: "running-and-frontmost")
  }

  @MainActor
  static func observe() -> SourceValiditySnapshot {
    let workspace = NSWorkspace.shared
    let running = Set(workspace.runningApplications.compactMap(\.bundleIdentifier))
    return SourceValiditySnapshot(
      frontmostBundleIdentifier: workspace.frontmostApplication?.bundleIdentifier,
      runningBundleIdentifiers: running
    )
  }
}
