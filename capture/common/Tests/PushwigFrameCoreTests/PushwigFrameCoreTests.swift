// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import PushwigFrameCore
import XCTest

final class PushwigFrameCoreTests: XCTestCase {
  private var retainedStorage: [UnsafeMutablePointer<UInt8>] = []

  override func tearDown() {
    retainedStorage.forEach { $0.deallocate() }
    retainedStorage.removeAll()
    super.tearDown()
  }

  func testDescriptorCarriesOnlyPortableFacts() {
    var descriptor = descriptorFixture()
    XCTAssertTrue(pw_frame_source_descriptor_is_valid(&descriptor))
    XCTAssertEqual(descriptor.source_id, 41)
    XCTAssertTrue(descriptor.cursor_free_or_separable)
    XCTAssertTrue(descriptor.linux_path_available)
  }

  func testDescriptorRejectsMissingIdentity() {
    var descriptor = descriptorFixture()
    descriptor.source_id = 0
    XCTAssertFalse(pw_frame_source_descriptor_is_valid(&descriptor))
  }

  func testIncompleteFrameRefuses() {
    var storage = fixture(width: 4, height: 4, stride: 20)
    var frame = rawFrame(bytes: &storage, width: 4, height: 4, stride: 20)
    frame.complete = false
    XCTAssertEqual(pw_raw_frame_validate(&frame), PW_STATUS_INVALID_FRAME)
  }

  func testPaddedStrideIsAcceptedAndShortStrideRefuses() {
    var storage = fixture(width: 4, height: 4, stride: 20)
    var frame = rawFrame(bytes: &storage, width: 4, height: 4, stride: 20)
    XCTAssertEqual(pw_raw_frame_validate(&frame), PW_STATUS_OK)
    frame.stride = 15
    XCTAssertEqual(pw_raw_frame_validate(&frame), PW_STATUS_INSUFFICIENT_INPUT)
  }

  func testQuadrantCropSelectsDifferentPixelsAndDoesNotLeakWholeSource() {
    var storage = quadrantFixture(width: 8, height: 8, stride: 40)
    var frame = rawFrame(bytes: &storage, width: 8, height: 8, stride: 40)
    var topLeft = [UInt8](repeating: 0, count: 4 * 4 * 4)
    var bottomRight = [UInt8](repeating: 0, count: 4 * 4 * 4)
    var resultA = PWTransformResult()
    var resultB = PWTransformResult()

    let statusA = topLeft.withUnsafeMutableBytes { output in
      pw_transform_to_opaque_bgra(
        &frame, crop(0, 0, 0.5, 0.5), destination(4, 4),
        output.bindMemory(to: UInt8.self).baseAddress, output.count, &resultA)
    }
    let statusB = bottomRight.withUnsafeMutableBytes { output in
      pw_transform_to_opaque_bgra(
        &frame, crop(0.5, 0.5, 0.5, 0.5), destination(4, 4),
        output.bindMemory(to: UInt8.self).baseAddress, output.count, &resultB)
    }
    XCTAssertEqual(statusA, PW_STATUS_OK)
    XCTAssertEqual(statusB, PW_STATUS_OK)
    XCTAssertNotEqual(topLeft, bottomRight)
    XCTAssertEqual(Set(pixels(topLeft)), [Pixel(b: 0, g: 0, r: 255, a: 255)])
    XCTAssertEqual(Set(pixels(bottomRight)), [Pixel(b: 0, g: 255, r: 255, a: 255)])
    XCTAssertEqual(resultA.pixels_written, 16)
    XCTAssertEqual(resultB.pixels_written, 16)
  }

  func testRGBAAndARGBConvertToOpaqueBGRA() {
    for (format, source) in [
      (PW_PIXEL_FORMAT_RGBA8888, [UInt8(9), 19, 29, 2]),
      (PW_PIXEL_FORMAT_ARGB8888, [UInt8(2), 9, 19, 29]),
    ] {
      var storage = source
      var frame = rawFrame(bytes: &storage, width: 1, height: 1, stride: 4)
      frame.pixel_format = format
      var output = [UInt8](repeating: 0, count: 4)
      let status = output.withUnsafeMutableBytes { bytes in
        pw_transform_to_opaque_bgra(
          &frame, crop(0, 0, 1, 1), destination(1, 1),
          bytes.bindMemory(to: UInt8.self).baseAddress, bytes.count, nil)
      }
      XCTAssertEqual(status, PW_STATUS_OK)
      XCTAssertEqual(output, [29, 19, 9, 255])
    }
  }

  func testAllOutputAlphaIsOpaque() {
    var storage = fixture(width: 7, height: 5, stride: 36)
    var frame = rawFrame(bytes: &storage, width: 7, height: 5, stride: 36)
    var output = [UInt8](repeating: 0, count: 11 * 9 * 4)
    XCTAssertEqual(
      transform(&frame, crop: crop(0, 0, 1, 1), output: &output, width: 11, height: 9), PW_STATUS_OK
    )
    XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 255 })
  }

  func testCenteredCoverIsUniformAndBounded() {
    var storage = fixture(width: 100, height: 100, stride: 400)
    var frame = rawFrame(bytes: &storage, width: 100, height: 100, stride: 400)
    var output = [UInt8](repeating: 0, count: 20 * 10 * 4)
    var result = PWTransformResult()
    let status = output.withUnsafeMutableBytes { bytes in
      pw_transform_to_opaque_bgra(
        &frame, crop(0, 0, 1, 1), destination(20, 10),
        bytes.bindMemory(to: UInt8.self).baseAddress, bytes.count, &result)
    }
    XCTAssertEqual(status, PW_STATUS_OK)
    XCTAssertEqual(result.effective_x, 0, accuracy: 0.000_001)
    XCTAssertEqual(result.effective_y, 25, accuracy: 0.000_001)
    XCTAssertEqual(result.effective_width, 100, accuracy: 0.000_001)
    XCTAssertEqual(result.effective_height, 50, accuracy: 0.000_001)
    XCTAssertEqual(result.uniform_scale, 0.2, accuracy: 0.000_001)
  }

  func testInvalidNormalizedCropsRefuse() {
    var storage = fixture(width: 4, height: 4, stride: 16)
    var frame = rawFrame(bytes: &storage, width: 4, height: 4, stride: 16)
    var output = [UInt8](repeating: 0, count: 16)
    for invalid in [crop(-0.1, 0, 1, 1), crop(0, 0, 0, 1), crop(0.5, 0, 0.6, 1)] {
      XCTAssertEqual(
        transform(&frame, crop: invalid, output: &output, width: 2, height: 2),
        PW_STATUS_INVALID_CROP)
    }
  }

  func testInvalidDestinationAndInsufficientOutputRefuse() {
    var storage = fixture(width: 4, height: 4, stride: 16)
    var frame = rawFrame(bytes: &storage, width: 4, height: 4, stride: 16)
    var output = [UInt8](repeating: 0, count: 15)
    XCTAssertEqual(
      transform(&frame, crop: crop(0, 0, 1, 1), output: &output, width: 2, height: 2),
      PW_STATUS_INSUFFICIENT_OUTPUT)
  }

  func testGenerationActivationAcceptsStrictlyIncreasingCompleteFrames() {
    var storage = fixture(width: 2, height: 2, stride: 8)
    var frame = rawFrame(bytes: &storage, width: 2, height: 2, stride: 8)
    var gate = PWGenerationGate()
    pw_generation_gate_activate(&gate, 41, 7)
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_OK)
    frame.sequence = 2
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_OK)
  }

  func testDuplicateSequenceRefuses() {
    var storage = fixture(width: 2, height: 2, stride: 8)
    var frame = rawFrame(bytes: &storage, width: 2, height: 2, stride: 8)
    var gate = PWGenerationGate()
    pw_generation_gate_activate(&gate, 41, 7)
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_OK)
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_STALE_SEQUENCE)
  }

  func testOldGenerationCannotPublishAfterRestart() {
    var storage = fixture(width: 2, height: 2, stride: 8)
    var frame = rawFrame(bytes: &storage, width: 2, height: 2, stride: 8)
    var gate = PWGenerationGate()
    pw_generation_gate_activate(&gate, 41, 8)
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_STALE_GENERATION)
  }

  func testSourceLossDeactivatesAuthority() {
    var storage = fixture(width: 2, height: 2, stride: 8)
    var frame = rawFrame(bytes: &storage, width: 2, height: 2, stride: 8)
    var gate = PWGenerationGate()
    pw_generation_gate_activate(&gate, 41, 7)
    pw_generation_gate_deactivate(&gate)
    XCTAssertEqual(pw_generation_gate_accept(&gate, &frame), PW_STATUS_STALE_GENERATION)
  }

  func testLatestFrameSupersedesWithoutFIFO() {
    var storage = fixture(width: 2, height: 2, stride: 8)
    var frame = rawFrame(bytes: &storage, width: 2, height: 2, stride: 8)
    var latest = PWLatestFrameState()
    XCTAssertEqual(pw_latest_frame_publish(&latest, &frame), PW_STATUS_OK)
    frame.sequence = 9
    XCTAssertEqual(pw_latest_frame_publish(&latest, &frame), PW_STATUS_OK)
    XCTAssertEqual(latest.sequence, 9)
    XCTAssertTrue(latest.has_frame)
  }

  func testClearDropsLatestFrame() {
    var state = PWLatestFrameState(source_id: 1, generation: 1, sequence: 3, has_frame: true)
    pw_latest_frame_clear(&state)
    XCTAssertFalse(state.has_frame)
    XCTAssertEqual(state.sequence, 0)
  }

  func testTransformUsesCallerOwnedFixedStorageAcrossManyFrames() {
    var storage = fixture(width: 32, height: 16, stride: 144)
    var frame = rawFrame(bytes: &storage, width: 32, height: 16, stride: 144)
    var output = [UInt8](repeating: 0, count: 56 * 16 * 4)
    let address = output.withUnsafeBytes { $0.baseAddress }
    for sequence in 1...1_100 {
      frame.sequence = UInt64(sequence)
      XCTAssertEqual(
        transform(&frame, crop: crop(0.1, 0.2, 0.8, 0.7), output: &output, width: 56, height: 16),
        PW_STATUS_OK)
    }
    XCTAssertEqual(address, output.withUnsafeBytes { $0.baseAddress })
  }

  func testNoPixelsOutsideDeclaredSourceCropLeak() {
    var storage = quadrantFixture(width: 16, height: 16, stride: 72)
    var frame = rawFrame(bytes: &storage, width: 16, height: 16, stride: 72)
    var output = [UInt8](repeating: 0, count: 28 * 8 * 4)
    XCTAssertEqual(
      transform(&frame, crop: crop(0, 0, 0.5, 0.5), output: &output, width: 28, height: 8),
      PW_STATUS_OK)
    XCTAssertEqual(Set(pixels(output)), [Pixel(b: 0, g: 0, r: 255, a: 255)])
  }

  private func descriptorFixture() -> PWFrameSourceDescriptor {
    PWFrameSourceDescriptor(
      source_id: 41, generation: 7, role: PW_SOURCE_ROLE_DISPLAY,
      width: 1_920, height: 1_080, pixel_format: PW_PIXEL_FORMAT_BGRA8888,
      interaction_safe: true, cursor_free_or_separable: true,
      supports_subregions: true, restartable: true, linux_path_available: true)
  }

  private func rawFrame(
    bytes: inout [UInt8], width: UInt32, height: UInt32, stride: Int
  ) -> PWRawFrame {
    // Own test storage explicitly; never escape an Array.withUnsafeBytes borrow.
    let storage = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count)
    bytes.withUnsafeBufferPointer { storage.initialize(from: $0.baseAddress!, count: $0.count) }
    retainedStorage.append(storage)
    return PWRawFrame(
      source_id: 41, generation: 7, sequence: 1,
      monotonic_timestamp_nanoseconds: 12, width: width, height: height,
      stride: stride, pixel_format: PW_PIXEL_FORMAT_BGRA8888, complete: true,
      bytes: storage, byte_capacity: bytes.count)
  }

  private func crop(_ x: Double, _ y: Double, _ width: Double, _ height: Double) -> PWNormalizedCrop
  {
    PWNormalizedCrop(x: x, y: y, width: width, height: height)
  }

  private func destination(_ width: UInt32, _ height: UInt32) -> PWDestination {
    PWDestination(width: width, height: height, stride: Int(width) * 4)
  }

  private func transform(
    _ frame: inout PWRawFrame, crop selected: PWNormalizedCrop,
    output: inout [UInt8], width: UInt32, height: UInt32
  ) -> PWStatus {
    output.withUnsafeMutableBytes { bytes in
      pw_transform_to_opaque_bgra(
        &frame, selected, destination(width, height),
        bytes.bindMemory(to: UInt8.self).baseAddress, bytes.count, nil)
    }
  }

  private func fixture(width: Int, height: Int, stride: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0xA5, count: stride * height)
    for y in 0..<height {
      for x in 0..<width {
        let offset = y * stride + x * 4
        bytes[offset] = UInt8((x * 11) & 0xFF)
        bytes[offset + 1] = UInt8((y * 17) & 0xFF)
        bytes[offset + 2] = UInt8(((x + y) * 7) & 0xFF)
        bytes[offset + 3] = UInt8((x + y) & 0x7F)
      }
    }
    return bytes
  }

  private func quadrantFixture(width: Int, height: Int, stride: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0xCD, count: stride * height)
    let colors = [
      Pixel(b: 0, g: 0, r: 255, a: 3), Pixel(b: 0, g: 255, r: 0, a: 7),
      Pixel(b: 255, g: 0, r: 0, a: 11), Pixel(b: 0, g: 255, r: 255, a: 13),
    ]
    for y in 0..<height {
      for x in 0..<width {
        let index = (y < height / 2 ? 0 : 2) + (x < width / 2 ? 0 : 1)
        let pixel = colors[index]
        let offset = y * stride + x * 4
        bytes[offset..<offset + 4] = [pixel.b, pixel.g, pixel.r, pixel.a][...]
      }
    }
    return bytes
  }

  private func pixels(_ bytes: [UInt8]) -> [Pixel] {
    stride(from: 0, to: bytes.count, by: 4).map {
      Pixel(b: bytes[$0], g: bytes[$0 + 1], r: bytes[$0 + 2], a: bytes[$0 + 3])
    }
  }
}

private struct Pixel: Hashable {
  let b: UInt8
  let g: UInt8
  let r: UInt8
  let a: UInt8
}
