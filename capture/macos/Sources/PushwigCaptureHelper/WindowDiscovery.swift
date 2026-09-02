// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation
import ScreenCaptureKit

struct WindowFact: Equatable {
  let windowID: CGWindowID
  let ownerBundleIdentifier: String
  let title: String?
  let frame: CGRect
  let isOnScreen: Bool
}

struct WindowCandidate {
  let fact: WindowFact
  let window: SCWindow?
}

enum WindowSelection: Equatable {
  case missing
  case ambiguous(Int)
  case selected(Int)
}

enum WindowDiscovery {
  static func currentCandidates(ownerBundleIdentifier: String) async throws -> [WindowCandidate] {
    let content = try await SCShareableContent.excludingDesktopWindows(
      true,
      onScreenWindowsOnly: false
    )
    return content.windows.compactMap { window in
      guard let owner = window.owningApplication,
        owner.bundleIdentifier == ownerBundleIdentifier,
        window.windowID != 0,
        window.frame.minX.isFinite,
        window.frame.minY.isFinite,
        window.frame.width.isFinite,
        window.frame.height.isFinite,
        window.frame.width > 0,
        window.frame.height > 0
      else {
        return nil
      }
      return WindowCandidate(
        fact: WindowFact(
          windowID: window.windowID,
          ownerBundleIdentifier: owner.bundleIdentifier,
          title: window.title,
          frame: window.frame,
          isOnScreen: window.isOnScreen
        ),
        window: window
      )
    }
  }

  static func resolve(
    facts: [WindowFact],
    selector: VisualProfile.WindowSelector
  ) -> WindowSelection {
    let matches = facts.enumerated().filter { indexed in
      let fact = indexed.element
      guard fact.ownerBundleIdentifier == selector.ownerBundleIdentifier,
        fact.isOnScreen,
        fact.frame.width >= selector.minimumWidthPoints,
        fact.frame.height >= selector.minimumHeightPoints
      else {
        return false
      }
      guard let titleContains = selector.titleContains else { return true }
      return fact.title?.contains(titleContains) == true
    }

    switch matches.count {
    case 0: return .missing
    case 1: return .selected(matches[0].offset)
    default: return .ambiguous(matches.count)
    }
  }

  static func select(
    candidates: [WindowCandidate],
    selector: VisualProfile.WindowSelector
  ) -> (selection: WindowSelection, candidate: WindowCandidate?) {
    let selection = resolve(facts: candidates.map(\.fact), selector: selector)
    guard case .selected(let index) = selection,
      candidates[index].window != nil
    else {
      return (selection, nil)
    }
    return (selection, candidates[index])
  }

  static func printInventory(
    candidates: [WindowCandidate],
    ownerBundleIdentifier: String
  ) {
    let sorted = candidates.sorted {
      if $0.fact.title != $1.fact.title {
        return ($0.fact.title ?? "") < ($1.fact.title ?? "")
      }
      return $0.fact.windowID < $1.fact.windowID
    }
    print("WINDOW_COUNT owner=\(quoted(ownerBundleIdentifier)) count=\(sorted.count)")
    for candidate in sorted {
      let fact = candidate.fact
      print(
        "WINDOW owner=\(quoted(fact.ownerBundleIdentifier)) "
          + "title=\(quoted(fact.title ?? "")) window_id=\(fact.windowID) "
          + "frame_points=\(format(fact.frame)) on_screen=\(fact.isOnScreen)"
      )
    }
  }

  static func format(_ rect: CGRect) -> String {
    String(
      format: "%.3f,%.3f,%.3f,%.3f",
      rect.origin.x,
      rect.origin.y,
      rect.width,
      rect.height
    )
  }

  private static func quoted(_ value: String) -> String {
    let safe =
      value
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
      .replacingOccurrences(of: "\n", with: "\\n")
      .replacingOccurrences(of: "\r", with: "\\r")
      .replacingOccurrences(of: "\t", with: "\\t")
    return "\"\(safe)\""
  }
}
