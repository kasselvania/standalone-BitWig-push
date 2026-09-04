// swift-tools-version: 6.0
// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import PackageDescription

let package = Package(
  name: "PushwigQuadrantFixture",
  platforms: [.macOS(.v14)],
  products: [.executable(name: "PushwigQuadrantFixture", targets: ["PushwigQuadrantFixture"])],
  targets: [
    .executableTarget(name: "PushwigQuadrantFixture", path: "Sources")
  ]
)
