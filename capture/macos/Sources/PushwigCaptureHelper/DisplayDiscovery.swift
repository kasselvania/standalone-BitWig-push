// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation
import ScreenCaptureKit

struct DisplayFact: Equatable {
  let displayID: UInt32
  // SCDisplay width/height and frame are ScreenCaptureKit screen-point facts.
  let width: Int
  let height: Int
  let frame: CGRect
  let isMain: Bool
}

struct DisplayCandidate {
  let fact: DisplayFact
  let display: SCDisplay?
}

enum DisplaySelection: Equatable {
  case missing
  case dimensionMismatch(DisplayFact)
  case ambiguous(Int)
  case selected(Int)
}

enum DisplayDiscovery {
  static func currentActiveFacts() throws -> [DisplayFact] {
    var displayCount: UInt32 = 0
    let countResult = CGGetActiveDisplayList(0, nil, &displayCount)
    guard countResult == .success else {
      throw CaptureConfigurationError.invalid(
        "CoreGraphics active-display count failed with code \(countResult.rawValue)"
      )
    }
    guard displayCount > 0 else { return [] }

    var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
    var returnedCount: UInt32 = 0
    let listResult = CGGetActiveDisplayList(displayCount, &displayIDs, &returnedCount)
    guard listResult == .success, returnedCount <= displayCount else {
      throw CaptureConfigurationError.invalid(
        "CoreGraphics active-display inventory failed with code \(listResult.rawValue)"
      )
    }

    return try displayIDs.prefix(Int(returnedCount)).map { displayID in
      // CGDisplayBounds is the point-space CoreGraphics display bound. Do not
      // use CGDisplayPixelsWide/High here: those pixel-unit APIs are not
      // comparable to SCDisplay.width/height on a scaled display.
      let frame = CGDisplayBounds(displayID)
      return DisplayFact(
        displayID: UInt32(displayID),
        width: try pointDimension(frame.width, label: "width", displayID: displayID),
        height: try pointDimension(frame.height, label: "height", displayID: displayID),
        frame: frame,
        isMain: CGDisplayIsMain(displayID) != 0
      )
    }
  }

  static func currentCandidates() async throws -> [DisplayCandidate] {
    let content = try await SCShareableContent.excludingDesktopWindows(
      true,
      onScreenWindowsOnly: false
    )
    let mainDisplayID = UInt32(CGMainDisplayID())
    return content.displays.map { display in
      DisplayCandidate(
        fact: DisplayFact(
          displayID: UInt32(display.displayID),
          width: display.width,
          height: display.height,
          frame: display.frame,
          isMain: UInt32(display.displayID) == mainDisplayID
        ),
        display: display
      )
    }
  }

  static func resolve(
    facts: [DisplayFact],
    displayID: UInt32,
    expectedWidth: Int,
    expectedHeight: Int
  ) -> DisplaySelection {
    let identifierMatches = facts.enumerated().filter { $0.element.displayID == displayID }
    guard !identifierMatches.isEmpty else { return .missing }
    guard identifierMatches.count == 1 else { return .ambiguous(identifierMatches.count) }

    let indexed = identifierMatches[0]
    guard indexed.element.width == expectedWidth,
      indexed.element.height == expectedHeight
    else {
      return .dimensionMismatch(indexed.element)
    }
    return .selected(indexed.offset)
  }

  static func select(
    candidates: [DisplayCandidate],
    displayID: UInt32,
    expectedWidth: Int,
    expectedHeight: Int
  ) throws -> DisplayCandidate {
    switch resolve(
      facts: candidates.map(\.fact),
      displayID: displayID,
      expectedWidth: expectedWidth,
      expectedHeight: expectedHeight
    ) {
    case .missing:
      throw CaptureConfigurationError.invalid(
        "configured display ID \(displayID) is unavailable"
      )
    case .dimensionMismatch(let observed):
      throw CaptureConfigurationError.invalid(
        "configured display point dimensions \(expectedWidth)x\(expectedHeight) do not match "
          + "observed \(observed.width)x\(observed.height) for display ID \(displayID)"
      )
    case .ambiguous(let count):
      throw CaptureConfigurationError.invalid(
        "display ID \(displayID) is ambiguous across \(count) ScreenCaptureKit displays"
      )
    case .selected(let index):
      guard candidates[index].display != nil else {
        throw CaptureConfigurationError.invalid("selected display has no capture object")
      }
      return candidates[index]
    }
  }

  static func validateCurrent(facts: [DisplayFact], expected: DisplayFact) throws {
    switch resolve(
      facts: facts,
      displayID: expected.displayID,
      expectedWidth: expected.width,
      expectedHeight: expected.height
    ) {
    case .missing:
      throw CaptureConfigurationError.invalid(
        "configured display ID \(expected.displayID) is no longer active"
      )
    case .dimensionMismatch(let observed):
      throw CaptureConfigurationError.invalid(
        "configured display point dimensions \(expected.width)x\(expected.height) no longer match "
          + "observed \(observed.width)x\(observed.height) for display ID \(expected.displayID)"
      )
    case .ambiguous(let count):
      throw CaptureConfigurationError.invalid(
        "display ID \(expected.displayID) is ambiguous across \(count) active displays"
      )
    case .selected(let index):
      guard facts[index] == expected else {
        throw CaptureConfigurationError.invalid(
          "configured display arrangement or main-display role changed"
        )
      }
    }
  }

  static func printInventory(candidates: [DisplayCandidate]) {
    print("DISPLAY_COUNT \(candidates.count)")
    for candidate in candidates.sorted(by: { $0.fact.displayID < $1.fact.displayID }) {
      let fact = candidate.fact
      print(
        "DISPLAY display_id=\(fact.displayID) width=\(fact.width) height=\(fact.height) "
          + "unit=screen-points "
          + "main=\(fact.isMain) frame=\(format(fact.frame))"
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

  private static func pointDimension(
    _ value: CGFloat,
    label: String,
    displayID: CGDirectDisplayID
  ) throws -> Int {
    guard value.isFinite, value > 0 else {
      throw CaptureConfigurationError.invalid(
        "active display \(displayID) has invalid point \(label)"
      )
    }
    let rounded = value.rounded()
    guard abs(value - rounded) < 0.001, rounded <= CGFloat(Int.max) else {
      throw CaptureConfigurationError.invalid(
        "active display \(displayID) has nonintegral point \(label)"
      )
    }
    return Int(rounded)
  }
}
