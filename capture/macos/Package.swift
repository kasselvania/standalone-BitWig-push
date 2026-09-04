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
  dependencies: [
    .package(path: "../common")
  ],
  targets: [
    .executableTarget(
      name: "PushwigCaptureHelper",
      dependencies: [
        .product(name: "PushwigFrameCore", package: "common")
      ],
      path: "Sources/PushwigCaptureHelper",
      linkerSettings: [
        .linkedFramework("AppKit"),
        .linkedFramework("AVFoundation"),
        .linkedFramework("CoreGraphics"),
        .linkedFramework("CoreImage"),
        .linkedFramework("CoreMedia"),
        .linkedFramework("CoreVideo"),
        .linkedFramework("ScreenCaptureKit"),
        .linkedFramework("Security"),
      ]
    ),
    .testTarget(
      name: "PushwigCaptureHelperTests",
      dependencies: ["PushwigCaptureHelper"],
      path: "Tests/PushwigCaptureHelperTests"
    ),
  ],
  swiftLanguageModes: [.v5]
)
