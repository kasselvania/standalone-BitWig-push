// swift-tools-version: 6.0
// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import PackageDescription

let package = Package(
  name: "PushwigFrameCore",
  products: [
    .library(name: "PushwigFrameCore", targets: ["PushwigFrameCore"])
  ],
  targets: [
    .target(
      name: "PushwigFrameCore",
      path: "Sources/PushwigFrameCore",
      publicHeadersPath: "include"
    ),
    .testTarget(
      name: "PushwigFrameCoreTests",
      dependencies: ["PushwigFrameCore"],
      path: "Tests/PushwigFrameCoreTests"
    ),
  ],
  cxxLanguageStandard: .cxx17
)
