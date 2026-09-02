// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import CoreVideo
import CryptoKit
import Foundation
import XCTest

@testable import PushwigCaptureHelper

final class V3WindowRelativeTests: XCTestCase {
  func testValidSchemaV1ProfileDecode() throws {
    let profile = try VisualProfile.decode(validProfileData())
    XCTAssertEqual(profile.id, "bitwig-device-chain")
    XCTAssertEqual(profile.window.ownerBundleIdentifier, "com.bitwig.studio")
    XCTAssertNil(profile.window.titleContains)
    XCTAssertEqual(profile.window.minimumWidthPoints, 800)
    XCTAssertEqual(profile.window.minimumHeightPoints, 500)
    XCTAssertEqual(profile.crop, try NormalizedCrop(x: 0.14, y: 0.68, width: 0.45, height: 0.305))
    XCTAssertEqual(profile.destination, try PushDestination(x: 400, y: 0, width: 560, height: 160))
    XCTAssertEqual(profile.fps, 30)
    XCTAssertEqual(profile.aspectPolicy, .centeredCover)
  }

  func testProfileRefusesUnknownSchema() {
    assertProfileInvalid(replacing: "\"schemaVersion\": 1", with: "\"schemaVersion\": 2")
  }

  func testProfileRefusesMalformedAndMissingObjects() {
    XCTAssertThrowsError(try VisualProfile.decode(Data("not-json".utf8)))
    assertProfileInvalid(replacing: "\"window\": {", with: "\"windows\": {")
  }

  func testProfileRefusesUnknownKeysAtEveryLevel() {
    assertProfileInvalid(
      replacing: "\"schemaVersion\": 1,", with: "\"schemaVersion\": 1, \"typo\": true,")
    assertProfileInvalid(
      replacing: "\"titleContains\": null,", with: "\"titleContains\": null, \"typo\": true,")
    assertProfileInvalid(replacing: "\"x\": 0.14,", with: "\"x\": 0.14, \"typo\": true,")
    assertProfileInvalid(replacing: "\"x\": 400,", with: "\"x\": 400, \"typo\": true,")
  }

  func testProfileRefusesBlankIdentityAndInvalidWindowSelector() {
    assertProfileInvalid(replacing: "\"id\": \"bitwig-device-chain\"", with: "\"id\": \"  \"")
    assertProfileInvalid(
      replacing: "\"ownerBundleIdentifier\": \"com.bitwig.studio\"",
      with: "\"ownerBundleIdentifier\": \"Bitwig\"")
    assertProfileInvalid(replacing: "\"titleContains\": null", with: "\"titleContains\": \"  \"")
    assertProfileInvalid(
      replacing: "\"minimumWidthPoints\": 800", with: "\"minimumWidthPoints\": 0")
    assertProfileInvalid(
      replacing: "\"minimumHeightPoints\": 500", with: "\"minimumHeightPoints\": -1")
  }

  func testProfileRefusesInvalidCropDestinationFPSAndAspect() {
    assertProfileInvalid(replacing: "\"width\": 0.45", with: "\"width\": 0.90")
    assertProfileInvalid(replacing: "\"width\": 560,", with: "\"width\": 561,")
    assertProfileInvalid(replacing: "\"fps\": 30", with: "\"fps\": 61")
    assertProfileInvalid(replacing: "\"centered-cover\"", with: "\"stretch\"")
  }

  func testProfileCLIIsShortAndCannotMixWithDisplayMode() throws {
    let configuration = try CaptureConfiguration.parse(arguments: [
      "--profile", "/tmp/profile.json",
      "--port", "45291",
      "--token-file", "/tmp/token",
    ])
    guard case .profile(let profile) = configuration.mode else {
      return XCTFail("expected profile mode")
    }
    XCTAssertEqual(profile.profileFile.path, "/tmp/profile.json")
    XCTAssertEqual(profile.port, 45_291)
    XCTAssertEqual(profile.tokenFile.path, "/tmp/token")
    XCTAssertThrowsError(
      try CaptureConfiguration.parse(arguments: [
        "--profile", "/tmp/profile.json",
        "--port", "45291",
        "--token-file", "/tmp/token",
        "--display-id", "5",
      ])
    )
  }

  func testWindowInventoryRequiresBoundedOwnerFilter() throws {
    XCTAssertEqual(
      try CaptureConfiguration.parse(arguments: [
        "--list-windows", "--owner-bundle-id", "com.bitwig.studio",
      ]).mode,
      .listWindows(ownerBundleIdentifier: "com.bitwig.studio")
    )
    XCTAssertThrowsError(try CaptureConfiguration.parse(arguments: ["--list-windows"]))
    XCTAssertThrowsError(
      try CaptureConfiguration.parse(arguments: [
        "--list-windows", "--owner-bundle-id", "com.bitwig.studio", "--fps", "30",
      ])
    )
  }

  func testWindowSelectorUniqueMissingAndAmbiguous() throws {
    let selector = try profile().window
    let selected = fact(
      id: 10, title: "New 1", frame: CGRect(x: 20, y: 30, width: 1200, height: 800))
    let otherOwner = fact(id: 11, owner: "com.apple.finder", title: "Finder")
    XCTAssertEqual(
      WindowDiscovery.resolve(facts: [selected, otherOwner], selector: selector),
      .selected(0)
    )
    XCTAssertEqual(WindowDiscovery.resolve(facts: [otherOwner], selector: selector), .missing)
    XCTAssertEqual(
      WindowDiscovery.resolve(facts: [selected, fact(id: 12, title: "New 2")], selector: selector),
      .ambiguous(2)
    )
  }

  func testWindowSelectorRefusesOffscreenAndBelowMinimum() throws {
    let selector = try profile().window
    XCTAssertEqual(
      WindowDiscovery.resolve(
        facts: [fact(id: 1, frame: CGRect(x: 0, y: 0, width: 799, height: 800))],
        selector: selector
      ),
      .missing
    )
    XCTAssertEqual(
      WindowDiscovery.resolve(
        facts: [fact(id: 1, isOnScreen: false)],
        selector: selector
      ),
      .missing
    )
  }

  func testWindowTitleConstraintIsExplicitSubstring() throws {
    let base = try profile()
    let selector = VisualProfile.WindowSelector(
      ownerBundleIdentifier: base.window.ownerBundleIdentifier,
      titleContains: "Live Set",
      minimumWidthPoints: base.window.minimumWidthPoints,
      minimumHeightPoints: base.window.minimumHeightPoints
    )
    XCTAssertEqual(
      WindowDiscovery.resolve(
        facts: [fact(id: 1, title: "Bitwig - Live Set")],
        selector: selector
      ),
      .selected(0)
    )
    XCTAssertEqual(
      WindowDiscovery.resolve(facts: [fact(id: 1, title: "Other")], selector: selector),
      .missing
    )
  }

  func testNormalizedCropUsesArbitraryContentBoundsAndNonzeroOrigin() throws {
    let crop = try NormalizedCrop(x: 0.25, y: 0.50, width: 0.50, height: 0.25)
    let bounds = CGRect(x: 37.5, y: 91.25, width: 1200, height: 800)
    let requested = try AspectMapping.requestedSourceRect(sourceBounds: bounds, crop: crop)
    XCTAssertEqual(requested, CGRect(x: 337.5, y: 491.25, width: 600, height: 200))
    XCTAssertTrue(bounds.contains(requested))

    let geometry = try WindowRelativeGeometry.make(
      contentRect: bounds,
      requestedSourceRect: requested,
      destination: PushDestination(x: 400, y: 0, width: 560, height: 160)
    )
    XCTAssertEqual(
      geometry.windowLocalEffectiveSourceRect,
      CGRect(x: 300, y: 414.285_714_285_714_3, width: 600, height: 171.428_571_428_571_42)
    )
    XCTAssertTrue(
      CGRect(origin: .zero, size: bounds.size).contains(
        geometry.windowLocalEffectiveSourceRect))
  }

  func testFractionalCenteredCoverToleranceAtSupportedFixtureResize() throws {
    let bounds = CGRect(
      x: 715.333_333_333,
      y: 229.666_666_667,
      width: 1_868.000_000_001,
      height: 1_021.000_000_001
    )
    let requested = try AspectMapping.requestedSourceRect(
      sourceBounds: bounds,
      crop: try NormalizedCrop(x: 0.14, y: 0.68, width: 0.45, height: 0.305)
    )
    let geometry = try WindowRelativeGeometry.make(
      contentRect: bounds,
      requestedSourceRect: requested,
      destination: try PushDestination(x: 400, y: 0, width: 560, height: 160)
    )

    XCTAssertTrue(
      AspectMapping.contains(geometry.mapping.effectiveSourceRect.cgRect, within: bounds))
    XCTAssertTrue(
      AspectMapping.contains(
        geometry.windowLocalEffectiveSourceRect,
        within: CGRect(origin: .zero, size: bounds.size)
      )
    )
    XCTAssertEqual(geometry.mapping.effectiveSourceAspect, 3.5, accuracy: 1e-12)
  }

  func testResizeRecomputesWindowRelativeGeometry() throws {
    let profile = try profile()
    let smallBounds = CGRect(x: 5, y: 7, width: 1000, height: 700)
    let largeBounds = CGRect(x: 5, y: 7, width: 1600, height: 1000)
    let smallRequested = try AspectMapping.requestedSourceRect(
      sourceBounds: smallBounds,
      crop: profile.crop
    )
    let largeRequested = try AspectMapping.requestedSourceRect(
      sourceBounds: largeBounds,
      crop: profile.crop
    )
    XCTAssertNotEqual(smallRequested.size, largeRequested.size)
    XCTAssertEqual(smallRequested.minX, 145, accuracy: 0.000_001)
    XCTAssertEqual(largeRequested.minX, 229, accuracy: 0.000_001)
    for (bounds, requested) in [(smallBounds, smallRequested), (largeBounds, largeRequested)] {
      let mapping = try AspectMapping.centeredCover(
        requestedSourceRect: requested,
        sourceBounds: bounds,
        destination: profile.destination
      )
      XCTAssertEqual(mapping.effectiveSourceAspect, 3.5, accuracy: 1e-12)
      XCTAssertTrue(bounds.contains(mapping.effectiveSourceRect.cgRect))
    }
  }

  func testFullWindowCaptureSizingUsesNativeScaleUntilBounded() throws {
    let native = try FullWindowCaptureSizing.make(
      contentSizePoints: CGSize(width: 800, height: 500),
      pointPixelScale: 2
    )
    XCTAssertEqual(native.width, 1_600)
    XCTAssertEqual(native.height, 1_000)
    XCTAssertEqual(native.pointToPixelScaleX, 2, accuracy: 1e-12)
    XCTAssertEqual(native.pointToPixelScaleY, 2, accuracy: 1e-12)

    let bounded = try FullWindowCaptureSizing.make(
      contentSizePoints: CGSize(width: 1_979, height: 967),
      pointPixelScale: 2
    )
    XCTAssertEqual(bounded.width, 2_560)
    XCTAssertLessThanOrEqual(bounded.height, FullWindowCaptureSizing.maximumHeightPixels)
    XCTAssertLessThanOrEqual(
      bounded.width * bounded.height,
      FullWindowCaptureSizing.maximumPixels
    )
    XCTAssertEqual(
      bounded.pointToPixelScaleX,
      bounded.pointToPixelScaleY,
      accuracy: 0.001
    )
  }

  func testWindowFramePlanKeepsPixelCropInBoundsAndUniform() throws {
    let destination = try PushDestination(x: 400, y: 0, width: 560, height: 160)
    let plan = try WindowFramePlan.make(
      sourceWidth: 2_560,
      sourceHeight: 1_250,
      crop: NormalizedCrop(x: 0.14, y: 0.68, width: 0.45, height: 0.305),
      destination: destination
    )
    let sourceBounds = CGRect(x: 0, y: 0, width: 2_560, height: 1_250)
    XCTAssertTrue(AspectMapping.contains(plan.topLeftPixelCrop, within: sourceBounds))
    XCTAssertTrue(AspectMapping.contains(plan.coreImageCrop, within: sourceBounds))
    XCTAssertEqual(plan.mapping.effectiveSourceAspect, 3.5, accuracy: 1e-12)
    XCTAssertEqual(
      plan.topLeftPixelCrop.minY + plan.coreImageCrop.minY + plan.topLeftPixelCrop.height,
      1_250,
      accuracy: 1e-9
    )
  }

  func testTwoNonoverlappingNormalizedCropsSelectDifferentGeneratedRegions() throws {
    let pixelBuffer = try quadrantPixelBuffer(width: 8, height: 8)
    let destination = try PushDestination(x: 0, y: 0, width: 4, height: 4)
    let processor = WindowFrameProcessor(destination: destination)
    let cropA = try WindowFramePlan.make(
      sourceWidth: 8,
      sourceHeight: 8,
      crop: NormalizedCrop(x: 0, y: 0, width: 0.5, height: 0.5),
      destination: destination
    )
    let cropB = try WindowFramePlan.make(
      sourceWidth: 8,
      sourceHeight: 8,
      crop: NormalizedCrop(x: 0.5, y: 0.5, width: 0.5, height: 0.5),
      destination: destination
    )
    var outputA = [UInt8](repeating: 0, count: destination.payloadBytes)
    var outputB = [UInt8](repeating: 0, count: destination.payloadBytes)
    let timingA = try processor.render(
      pixelBuffer: pixelBuffer,
      plan: cropA,
      destinationBytes: &outputA
    )
    _ = try processor.render(
      pixelBuffer: pixelBuffer,
      plan: cropB,
      destinationBytes: &outputB
    )

    XCTAssertGreaterThan(timingA.sourceBytesPerRow, 8 * 4)
    XCTAssertEqual(Set(pixels(outputA)), [BGRAPixel(blue: 0, green: 0, red: 255, alpha: 255)])
    XCTAssertEqual(
      Set(pixels(outputB)),
      [BGRAPixel(blue: 0, green: 255, red: 255, alpha: 255)]
    )
    XCTAssertNotEqual(sha256(outputA), sha256(outputB))
    XCTAssertFalse(outputA.containsSubsequence([0, 255, 255, 255]))
    XCTAssertFalse(outputB.containsSubsequence([0, 0, 255, 255]))
  }

  func testWindowFrameProcessorNormalizesAlphaAndReusesDestinationStorage() throws {
    let pixelBuffer = try quadrantPixelBuffer(width: 8, height: 8)
    let destination = try PushDestination(x: 0, y: 0, width: 4, height: 4)
    let plan = try WindowFramePlan.make(
      sourceWidth: 8,
      sourceHeight: 8,
      crop: NormalizedCrop(x: 0, y: 0, width: 0.5, height: 0.5),
      destination: destination
    )
    let processor = WindowFrameProcessor(destination: destination)
    var output = [UInt8](repeating: 0, count: destination.payloadBytes)
    let initialAddress = storageAddress(output)
    for _ in 0..<32 {
      _ = try processor.render(
        pixelBuffer: pixelBuffer,
        plan: plan,
        destinationBytes: &output
      )
      XCTAssertEqual(storageAddress(output), initialAddress)
      XCTAssertTrue(BGRANormalizer.hasOnlyOpaqueAlpha(output))
    }
  }

  func testWindowPixelCropRecomputesAfterResize() throws {
    let destination = try PushDestination(x: 400, y: 0, width: 560, height: 160)
    let crop = try profile().crop
    let small = try WindowFramePlan.make(
      sourceWidth: 1_600,
      sourceHeight: 1_000,
      crop: crop,
      destination: destination
    )
    let large = try WindowFramePlan.make(
      sourceWidth: 2_560,
      sourceHeight: 1_250,
      crop: crop,
      destination: destination
    )
    XCTAssertNotEqual(small.topLeftPixelCrop, large.topLeftPixelCrop)
    XCTAssertEqual(small.mapping.effectiveSourceAspect, 3.5, accuracy: 1e-12)
    XCTAssertEqual(large.mapping.effectiveSourceAspect, 3.5, accuracy: 1e-12)
  }

  func testWindowSignatureIgnoresMoveButDetectsResizeAndRecreation() {
    let original = WindowCaptureSignature(
      fact: fact(id: 7, frame: CGRect(x: 0, y: 0, width: 1200, height: 800))
    )
    let moved = WindowCaptureSignature(
      fact: fact(id: 7, frame: CGRect(x: 900, y: 300, width: 1200, height: 800))
    )
    let resized = WindowCaptureSignature(
      fact: fact(id: 7, frame: CGRect(x: 900, y: 300, width: 1199, height: 800))
    )
    let recreated = WindowCaptureSignature(
      fact: fact(id: 8, frame: CGRect(x: 900, y: 300, width: 1200, height: 800))
    )
    XCTAssertEqual(original, moved)
    XCTAssertNotEqual(original, resized)
    XCTAssertNotEqual(original, recreated)
  }

  func testGenerationALossGenerationBRejectsOldGeneration() {
    var authority = CaptureGenerationAuthority()
    authority.activate(1)
    XCTAssertTrue(authority.permits(1))
    XCTAssertTrue(authority.deactivate(1))
    XCTAssertFalse(authority.permits(1))
    XCTAssertFalse(authority.deactivate(1))
    authority.activate(2)
    XCTAssertTrue(authority.permits(2))
    XCTAssertFalse(authority.permits(1))
  }

  private func profile() throws -> VisualProfile {
    try VisualProfile.decode(validProfileData())
  }

  private func fact(
    id: CGWindowID,
    owner: String = "com.bitwig.studio",
    title: String? = "New 1",
    frame: CGRect = CGRect(x: 0, y: 0, width: 1200, height: 800),
    isOnScreen: Bool = true
  ) -> WindowFact {
    WindowFact(
      windowID: id,
      ownerBundleIdentifier: owner,
      title: title,
      frame: frame,
      isOnScreen: isOnScreen
    )
  }

  private func assertProfileInvalid(
    replacing target: String,
    with replacement: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let text = String(decoding: validProfileData(), as: UTF8.self)
      .replacingOccurrences(of: target, with: replacement)
    XCTAssertThrowsError(
      try VisualProfile.decode(Data(text.utf8)),
      file: file,
      line: line
    )
  }

  private func validProfileData() -> Data {
    Data(
      """
      {
        "schemaVersion": 1,
        "id": "bitwig-device-chain",
        "window": {
          "ownerBundleIdentifier": "com.bitwig.studio",
          "titleContains": null,
          "minimumWidthPoints": 800,
          "minimumHeightPoints": 500
        },
        "crop": {
          "x": 0.14,
          "y": 0.68,
          "width": 0.45,
          "height": 0.305
        },
        "destination": {
          "x": 400,
          "y": 0,
          "width": 560,
          "height": 160
        },
        "fps": 30,
        "aspectPolicy": "centered-cover"
      }
      """.utf8
    )
  }

  private func quadrantPixelBuffer(width: Int, height: Int) throws -> CVPixelBuffer {
    var pixelBuffer: CVPixelBuffer?
    let attributes = [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary
    XCTAssertEqual(
      CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_32BGRA,
        attributes,
        &pixelBuffer
      ),
      kCVReturnSuccess
    )
    guard let pixelBuffer else { throw WindowFrameProcessorError.invalidSourceGeometry }
    XCTAssertEqual(CVPixelBufferLockBaseAddress(pixelBuffer, []), kCVReturnSuccess)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    memset(baseAddress, 0xA5, bytesPerRow * height)
    let bytes = baseAddress.assumingMemoryBound(to: UInt8.self)
    for y in 0..<height {
      for x in 0..<width {
        let pixel: BGRAPixel
        switch (x < width / 2, y < height / 2) {
        case (true, true): pixel = BGRAPixel(blue: 0, green: 0, red: 255, alpha: 17)
        case (false, true): pixel = BGRAPixel(blue: 0, green: 255, red: 0, alpha: 31)
        case (true, false): pixel = BGRAPixel(blue: 255, green: 0, red: 0, alpha: 47)
        case (false, false): pixel = BGRAPixel(blue: 0, green: 255, red: 255, alpha: 63)
        }
        let offset = y * bytesPerRow + x * 4
        bytes[offset] = pixel.blue
        bytes[offset + 1] = pixel.green
        bytes[offset + 2] = pixel.red
        bytes[offset + 3] = pixel.alpha
      }
    }
    return pixelBuffer
  }

  private func pixels(_ bytes: [UInt8]) -> [BGRAPixel] {
    stride(from: 0, to: bytes.count, by: 4).map {
      BGRAPixel(
        blue: bytes[$0],
        green: bytes[$0 + 1],
        red: bytes[$0 + 2],
        alpha: bytes[$0 + 3]
      )
    }
  }

  private func sha256(_ bytes: [UInt8]) -> String {
    SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
  }

  private func storageAddress(_ bytes: [UInt8]) -> UInt {
    bytes.withUnsafeBytes { UInt(bitPattern: $0.baseAddress!) }
  }
}

private struct BGRAPixel: Hashable {
  let blue: UInt8
  let green: UInt8
  let red: UInt8
  let alpha: UInt8
}

extension Array where Element == UInt8 {
  fileprivate func containsSubsequence(_ bytes: [UInt8]) -> Bool {
    guard !bytes.isEmpty, bytes.count <= count else { return false }
    return (0...(count - bytes.count)).contains { start in
      Array(self[start..<(start + bytes.count)]) == bytes
    }
  }
}
