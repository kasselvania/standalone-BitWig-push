// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation
import ScreenCaptureKit

struct WindowDescriptor: Equatable {
    let ownerBundleIdentifier: String
    let exactTitle: String
    let role: SourceRole
}

struct WindowCandidate {
    let windowID: CGWindowID
    let ownerBundleIdentifier: String
    let applicationName: String
    let title: String
    let frame: CGRect
    let isOnScreen: Bool
    let window: SCWindow?
}

enum WindowSelection {
    case missing
    case unique(WindowCandidate)
    case ambiguous([WindowCandidate])
}

enum WindowDiscovery {
    static func currentCandidates() async throws -> [WindowCandidate] {
        let content = try await SCShareableContent.excludingDesktopWindows(
            true,
            onScreenWindowsOnly: false
        )
        return content.windows.compactMap { window in
            guard let owner = window.owningApplication,
                  let title = window.title,
                  !owner.bundleIdentifier.isEmpty,
                  !title.isEmpty,
                  window.frame.width > 0,
                  window.frame.height > 0 else {
                return nil
            }
            return WindowCandidate(
                windowID: window.windowID,
                ownerBundleIdentifier: owner.bundleIdentifier,
                applicationName: owner.applicationName,
                title: title,
                frame: window.frame,
                isOnScreen: window.isOnScreen,
                window: window
            )
        }
    }

    static func resolve(
        candidates: [WindowCandidate],
        descriptor: WindowDescriptor
    ) -> WindowSelection {
        let matches = candidates.filter {
            $0.isOnScreen
                && $0.ownerBundleIdentifier == descriptor.ownerBundleIdentifier
                && $0.title == descriptor.exactTitle
        }
        switch matches.count {
        case 0:
            return .missing
        case 1:
            return .unique(matches[0])
        default:
            return .ambiguous(matches)
        }
    }

    static func printInventory(
        candidates: [WindowCandidate],
        ownerFilter: String?,
        titleFilter: String?
    ) {
        let filtered = candidates.filter { candidate in
            (ownerFilter == nil || candidate.ownerBundleIdentifier == ownerFilter)
                && (titleFilter == nil || candidate.title == titleFilter)
        }
        print("WINDOW_COUNT \(filtered.count)")
        for candidate in filtered.sorted(by: inventoryOrder) {
            print(
                "WINDOW owner=\(quoted(candidate.ownerBundleIdentifier)) "
                    + "application=\(quoted(candidate.applicationName)) "
                    + "title=\(quoted(candidate.title)) "
                    + "window_id=\(candidate.windowID) "
                    + "frame=\(format(candidate.frame)) "
                    + "on_screen=\(candidate.isOnScreen)"
            )
        }
    }

    private static func inventoryOrder(_ lhs: WindowCandidate, _ rhs: WindowCandidate) -> Bool {
        if lhs.ownerBundleIdentifier != rhs.ownerBundleIdentifier {
            return lhs.ownerBundleIdentifier < rhs.ownerBundleIdentifier
        }
        if lhs.title != rhs.title { return lhs.title < rhs.title }
        return lhs.windowID < rhs.windowID
    }

    private static func quoted(_ value: String) -> String {
        let safe = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(safe)\""
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
}
