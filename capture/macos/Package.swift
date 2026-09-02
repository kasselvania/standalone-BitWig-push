// swift-tools-version: 6.0
// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import PackageDescription

let package = Package(
    name: "PushwigCaptureHelper",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PushwigCaptureHelper", targets: ["PushwigCaptureHelper"])
    ],
    targets: [
        .executableTarget(
            name: "PushwigCaptureHelper",
            path: "Sources/PushwigCaptureHelper",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("ScreenCaptureKit"),
                .linkedFramework("Security")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
