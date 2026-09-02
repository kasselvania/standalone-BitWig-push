// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Darwin
import Foundation
import XCTest

@testable import PushwigCaptureHelper

final class PushwigCaptureHelperTests: XCTestCase {
  private let validArguments = [
    "--display-id", "5",
    "--expected-display-width", "3430",
    "--expected-display-height", "1447",
    "--crop-normalized", "0.14,0.68,0.45,0.305",
    "--destination", "400,0,560,160",
    "--fps", "30",
    "--port", "45291",
    "--token-file", "/private/tmp/pushwig-token",
    "--required-frontmost-bundle-id", "com.bitwig.studio",
  ]

  func testValidConfigurationIsExplicit() throws {
    let configuration = try CaptureConfiguration.parse(arguments: validArguments)
    XCTAssertFalse(configuration.listDisplays)
    XCTAssertEqual(configuration.displayID, 5)
    XCTAssertEqual(configuration.expectedDisplayWidth, 3430)
    XCTAssertEqual(configuration.expectedDisplayHeight, 1447)
    XCTAssertEqual(
      configuration.normalizedCrop,
      try NormalizedCrop(
        x: 0.14,
        y: 0.68,
        width: 0.45,
        height: 0.305
      ))
    XCTAssertEqual(
      configuration.destination,
      try PushDestination(
        x: 400,
        y: 0,
        width: 560,
        height: 160
      ))
    XCTAssertEqual(configuration.fps, 30)
    XCTAssertEqual(configuration.port, 45_291)
    XCTAssertEqual(configuration.requiredFrontmostBundleIdentifier, "com.bitwig.studio")
  }

  func testListDisplaysCannotCarryCaptureConfiguration() throws {
    let configuration = try CaptureConfiguration.parse(arguments: ["--list-displays"])
    XCTAssertTrue(configuration.listDisplays)
    assertInvalid(["--list-displays", "--display-id", "5"])
  }

  func testConfigurationNegativeMatrix() {
    assertInvalid(removing: "--display-id")
    assertInvalid(replacing: "--display-id", with: "0")
    assertInvalid(removing: "--expected-display-width")
    assertInvalid(replacing: "--expected-display-width", with: "0")
    assertInvalid(removing: "--expected-display-height")
    assertInvalid(replacing: "--expected-display-height", with: "0")
    assertInvalid(replacing: "--crop-normalized", with: "nan,0,0.5,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "inf,0,0.5,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "-0.1,0,0.5,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "0,0,0,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "0,0,0.5,0")
    assertInvalid(replacing: "--crop-normalized", with: "0,0,1.1,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "0.6,0,0.5,0.5")
    assertInvalid(replacing: "--crop-normalized", with: "0,0.6,0.5,0.5")
    assertInvalid(replacing: "--destination", with: "-1,0,10,10")
    assertInvalid(replacing: "--destination", with: "0,0,0,10")
    assertInvalid(replacing: "--destination", with: "0,0,10,0")
    assertInvalid(replacing: "--destination", with: "959,0,2,1")
    assertInvalid(removing: "--token-file")
    assertInvalid(replacing: "--port", with: "1023")
    assertInvalid(replacing: "--fps", with: "61")
    assertInvalid(replacing: "--required-frontmost-bundle-id", with: "not a bundle")
    assertInvalid(validArguments + ["--fps", "15"])
    assertInvalid(validArguments + ["--unknown", "value"])
  }

  func testDisplaySelectionRequiresExactIdentifierAndDimensions() {
    let first = DisplayFact(
      displayID: 5,
      width: 3430,
      height: 1447,
      frame: CGRect(x: 0, y: 0, width: 3430, height: 1447),
      isMain: true
    )
    let second = DisplayFact(
      displayID: 8,
      width: 1920,
      height: 1080,
      frame: CGRect(x: 3430, y: 0, width: 1920, height: 1080),
      isMain: false
    )
    XCTAssertEqual(
      DisplayDiscovery.resolve(
        facts: [first, second],
        displayID: 5,
        expectedWidth: 3430,
        expectedHeight: 1447
      ),
      .selected(0)
    )
    XCTAssertEqual(
      DisplayDiscovery.resolve(
        facts: [first, second],
        displayID: 7,
        expectedWidth: 3430,
        expectedHeight: 1447
      ),
      .missing
    )
    XCTAssertEqual(
      DisplayDiscovery.resolve(
        facts: [first],
        displayID: 5,
        expectedWidth: 3429,
        expectedHeight: 1447
      ),
      .dimensionMismatch(first)
    )
    XCTAssertEqual(
      DisplayDiscovery.resolve(
        facts: [first, first],
        displayID: 5,
        expectedWidth: 3430,
        expectedHeight: 1447
      ),
      .ambiguous(2)
    )
  }

  func testCurrentDisplayValidationRejectsFixtureDrift() throws {
    let expected = DisplayFact(
      displayID: 5,
      width: 3430,
      height: 1447,
      frame: CGRect(x: 0, y: 0, width: 3430, height: 1447),
      isMain: true
    )
    XCTAssertNoThrow(try DisplayDiscovery.validateCurrent(facts: [expected], expected: expected))

    let rearranged = DisplayFact(
      displayID: 5,
      width: 3430,
      height: 1447,
      frame: CGRect(x: 1920, y: 0, width: 3430, height: 1447),
      isMain: false
    )
    XCTAssertThrowsError(
      try DisplayDiscovery.validateCurrent(facts: [rearranged], expected: expected)
    )
    XCTAssertThrowsError(try DisplayDiscovery.validateCurrent(facts: [], expected: expected))
  }

  func testFixtureCenteredCoverIsMaximalFractionalAndUniform() throws {
    let crop = try NormalizedCrop(x: 0.14, y: 0.68, width: 0.45, height: 0.305)
    let destination = try PushDestination(x: 400, y: 0, width: 560, height: 160)
    let mapping = try AspectMapping.centeredCover(
      displayWidth: 3430,
      displayHeight: 1447,
      crop: crop,
      destination: destination
    )
    XCTAssertEqual(mapping.requestedSourceRect.origin.x, 480.2, accuracy: 0.000_001)
    XCTAssertEqual(mapping.requestedSourceRect.origin.y, 983.96, accuracy: 0.000_001)
    XCTAssertEqual(mapping.requestedSourceRect.width, 1543.5, accuracy: 0.000_001)
    XCTAssertEqual(mapping.requestedSourceRect.height, 441.335, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.x, 480.2, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.y, 984.1275, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.width, 1543.5, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.height, 441.0, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceAspect, 3.5, accuracy: 0.000_000_001)
    XCTAssertEqual(mapping.destinationAspect, 3.5, accuracy: 0.000_000_001)
    XCTAssertEqual(mapping.uniformScale, 560.0 / 1543.5, accuracy: 0.000_000_001)
    XCTAssertGreaterThanOrEqual(mapping.croppedLeft, 0)
    XCTAssertGreaterThanOrEqual(mapping.croppedTop, 0)
    XCTAssertGreaterThanOrEqual(mapping.croppedRight, 0)
    XCTAssertGreaterThanOrEqual(mapping.croppedBottom, 0)
  }

  func testNonCleanGCDDestinationKeepsMaximalCenteredCover() throws {
    let crop = try NormalizedCrop(x: 0.14, y: 0.68, width: 0.45, height: 0.305)
    let destination = try PushDestination(x: 400, y: 0, width: 559, height: 160)
    let mapping = try AspectMapping.centeredCover(
      displayWidth: 3430,
      displayHeight: 1447,
      crop: crop,
      destination: destination
    )

    XCTAssertEqual(mapping.effectiveSourceRect.x, 480.992_921_875, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.y, 983.96, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.width, 1541.914_156_25, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceRect.height, 441.335, accuracy: 0.000_001)
    XCTAssertEqual(mapping.effectiveSourceAspect, 559.0 / 160.0, accuracy: 1e-12)
    XCTAssertEqual(mapping.uniformScale, 559.0 / 1541.914_156_25, accuracy: 1e-12)
    XCTAssertGreaterThan(
      mapping.effectiveSourceRect.width * mapping.effectiveSourceRect.height
        / (mapping.requestedSourceRect.width * mapping.requestedSourceRect.height),
      0.998
    )
  }

  func testCenteredCoverHandlesWiderAndTallerPointCrops() throws {
    let destination = try PushDestination(x: 0, y: 0, width: 200, height: 100)
    let wider = try AspectMapping.centeredCover(
      requestedSourceRect: CGRect(x: 100, y: 200, width: 800, height: 100),
      displayWidth: 1000,
      displayHeight: 1000,
      destination: destination
    )
    XCTAssertEqual(
      wider.effectiveSourceRect, ScreenPointRect(x: 400, y: 200, width: 200, height: 100))
    XCTAssertEqual(wider.uniformScale, 1, accuracy: 1e-12)

    let taller = try AspectMapping.centeredCover(
      requestedSourceRect: CGRect(x: 100, y: 100, width: 200, height: 800),
      displayWidth: 1000,
      displayHeight: 1000,
      destination: destination
    )
    XCTAssertEqual(
      taller.effectiveSourceRect, ScreenPointRect(x: 100, y: 450, width: 200, height: 100))
    XCTAssertEqual(taller.uniformScale, 1, accuracy: 1e-12)

    for mapping in [wider, taller] {
      XCTAssertTrue(mapping.requestedSourceRect.contains(mapping.effectiveSourceRect.cgRect))
      XCTAssertEqual(mapping.effectiveSourceAspect, mapping.destinationAspect, accuracy: 1e-12)
      XCTAssertEqual(mapping.croppedLeft, mapping.croppedRight, accuracy: 1e-12)
      XCTAssertEqual(mapping.croppedTop, mapping.croppedBottom, accuracy: 1e-12)
    }
  }

  func testCenteredCoverRejectsInvalidAndNonfinitePointGeometry() throws {
    let destination = try PushDestination(x: 0, y: 0, width: 200, height: 100)
    for requested in [
      CGRect(x: 0, y: 0, width: CGFloat.nan, height: 100),
      CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 100),
      CGRect(x: -1, y: 0, width: 100, height: 100),
      CGRect(x: 0, y: 0, width: 0, height: 100),
      CGRect(x: 950, y: 0, width: 100, height: 100),
    ] {
      XCTAssertThrowsError(
        try AspectMapping.centeredCover(
          requestedSourceRect: requested,
          displayWidth: 1000,
          displayHeight: 1000,
          destination: destination
        )
      )
    }
  }

  func testBGRACopyExcludesPaddingAndForcesOpaqueAlpha() throws {
    let source: [UInt8] = [
      1, 2, 3, 0, 4, 5, 6, 19, 90, 91, 92, 93,
      7, 8, 9, 21, 10, 11, 12, 0, 94, 95, 96, 97,
    ]
    var output = [UInt8](repeating: 0, count: 16)
    try source.withUnsafeBytes { bytes in
      try BGRANormalizer.copyOpaque(
        source: bytes.baseAddress!,
        sourceBytesPerRow: 12,
        width: 2,
        height: 2,
        destination: &output
      )
    }
    XCTAssertEqual(
      output,
      [
        1, 2, 3, 255, 4, 5, 6, 255,
        7, 8, 9, 255, 10, 11, 12, 255,
      ])
    XCTAssertTrue(BGRANormalizer.hasOnlyOpaqueAlpha(output))
    XCTAssertFalse(output.contains(90))
    XCTAssertFalse(output.contains(94))
  }

  func testProtocolHeaderUsesExactNetworkOrderLayout() {
    var header = [UInt8](repeating: 0xAA, count: ProtocolHeaderWriter.headerLength)
    ProtocolHeaderWriter.write(
      into: &header,
      messageType: ProtocolHeaderWriter.messageFrame,
      format: ProtocolHeaderWriter.formatOpaqueBGRA,
      sessionHigh: 0x0102_0304_0506_0708,
      sessionLow: 0x1112_1314_1516_1718,
      sequence: 0x2122_2324_2526_2728,
      destinationX: 400,
      destinationY: 0,
      width: 560,
      height: 160,
      stride: 2240,
      payloadLength: 358_400
    )
    XCTAssertEqual(readUInt32(header, 0), 0x5057_5852)
    XCTAssertEqual(readUInt16(header, 4), 1)
    XCTAssertEqual(readUInt16(header, 6), 80)
    XCTAssertEqual(readUInt32(header, 8), 2)
    XCTAssertEqual(readUInt32(header, 12), 0)
    XCTAssertEqual(readUInt32(header, 16), 1)
    XCTAssertEqual(readUInt32(header, 20), 0)
    XCTAssertEqual(readUInt64(header, 24), 0x0102_0304_0506_0708)
    XCTAssertEqual(readUInt64(header, 32), 0x1112_1314_1516_1718)
    XCTAssertEqual(readUInt64(header, 40), 0x2122_2324_2526_2728)
    XCTAssertEqual(readUInt32(header, 48), 400)
    XCTAssertEqual(readUInt32(header, 56), 560)
    XCTAssertEqual(readUInt32(header, 60), 160)
    XCTAssertEqual(readUInt32(header, 64), 2240)
    XCTAssertEqual(readUInt32(header, 68), 358_400)
    XCTAssertEqual(readUInt64(header, 72), 0)
  }

  func testSequenceIsPositiveStrictAndDoesNotWrap() throws {
    var sequence = ProtocolSequence()
    XCTAssertEqual(try sequence.next(), 1)
    XCTAssertEqual(try sequence.next(), 2)

    var final = ProtocolSequence(current: UInt64(Int64.max) - 1)
    XCTAssertEqual(try final.next(), UInt64(Int64.max))
    XCTAssertThrowsError(try final.next())
  }

  func testAuthoritySendsOneClearForOneLossTransition() {
    var authority = VisualAuthorityState()
    XCTAssertFalse(authority.setGuardValid(true))
    XCTAssertFalse(authority.setCaptureActive(true))
    authority.markFramePublished()
    XCTAssertTrue(authority.setGuardValid(false))
    XCTAssertFalse(authority.setGuardValid(false))
    XCTAssertFalse(authority.setCaptureActive(false))
    XCTAssertFalse(authority.setGuardValid(true))
    XCTAssertFalse(authority.setCaptureActive(true))
    authority.markFramePublished()
    XCTAssertTrue(authority.setCaptureActive(false))
  }

  func testSourceValidityRequiresRunningAndFrontmost() {
    let required = "com.bitwig.studio"
    XCTAssertEqual(
      SourceValidityGate.evaluate(
        requiredBundleIdentifier: required,
        snapshot: SourceValiditySnapshot(
          frontmostBundleIdentifier: required,
          runningBundleIdentifiers: [required]
        )
      ),
      SourceValidityDecision(isValid: true, reason: "running-and-frontmost")
    )
    XCTAssertFalse(
      SourceValidityGate.evaluate(
        requiredBundleIdentifier: required,
        snapshot: SourceValiditySnapshot(
          frontmostBundleIdentifier: "com.apple.finder",
          runningBundleIdentifiers: [required, "com.apple.finder"]
        )
      ).isValid)
    XCTAssertFalse(
      SourceValidityGate.evaluate(
        requiredBundleIdentifier: required,
        snapshot: SourceValiditySnapshot(
          frontmostBundleIdentifier: required,
          runningBundleIdentifiers: []
        )
      ).isValid)
  }

  func testStalledReaderBoundsWriteClosesClientAndAllowsShutdown() throws {
    let server = try makeStalledLoopbackServer()
    defer { server.stop() }
    let token = try makeTokenFile()
    defer { try? FileManager.default.removeItem(at: token.deletingLastPathComponent()) }

    let client = try ExternalRasterProtocolClient(port: server.port, tokenFile: token)
    XCTAssertEqual(server.waitForHello(), .success)
    let destination = try PushDestination(x: 0, y: 0, width: 960, height: 160)
    let pixels = [UInt8](repeating: 0xFF, count: destination.payloadBytes)

    let start = DispatchTime.now().uptimeNanoseconds
    var failure: Error?
    for _ in 0..<1_024 {
      do {
        _ = try client.sendFrame(destination: destination, pixels: pixels)
      } catch {
        failure = error
        break
      }
    }
    let failureMilliseconds = Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000
    guard let failure else {
      return XCTFail("stalled reader never applied backpressure")
    }
    guard case ExternalRasterProtocolError.writeDeadlineExceeded = failure else {
      return XCTFail("unexpected stalled-reader failure: \(failure)")
    }
    XCTAssertGreaterThanOrEqual(failureMilliseconds, 150)
    XCTAssertLessThan(failureMilliseconds, 1_500)

    XCTAssertThrowsError(try client.sendFrame(destination: destination, pixels: pixels)) {
      guard case ExternalRasterProtocolError.closed = $0 else {
        return XCTFail("client remained open after bounded failure: \($0)")
      }
    }
    let shutdownStart = DispatchTime.now().uptimeNanoseconds
    client.close()
    XCTAssertLessThan(
      Double(DispatchTime.now().uptimeNanoseconds - shutdownStart) / 1_000_000,
      50
    )
  }

  private func assertInvalid(
    removing option: String, file: StaticString = #filePath, line: UInt = #line
  ) {
    var arguments = validArguments
    if let index = arguments.firstIndex(of: option) {
      arguments.removeSubrange(index...index + 1)
    }
    assertInvalid(arguments, file: file, line: line)
  }

  private func assertInvalid(
    replacing option: String,
    with replacement: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    var arguments = validArguments
    if let index = arguments.firstIndex(of: option) {
      arguments[index + 1] = replacement
    }
    assertInvalid(arguments, file: file, line: line)
  }

  private func assertInvalid(
    _ arguments: [String],
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertThrowsError(
      try CaptureConfiguration.parse(arguments: arguments),
      file: file,
      line: line
    ) { error in
      XCTAssertFalse(error.localizedDescription.isEmpty, file: file, line: line)
      XCTAssertLessThanOrEqual(error.localizedDescription.count, 240, file: file, line: line)
    }
  }

  private func readUInt16(_ bytes: [UInt8], _ offset: Int) -> UInt16 {
    UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1])
  }

  private func readUInt32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
    UInt32(readUInt16(bytes, offset)) << 16 | UInt32(readUInt16(bytes, offset + 2))
  }

  private func readUInt64(_ bytes: [UInt8], _ offset: Int) -> UInt64 {
    UInt64(readUInt32(bytes, offset)) << 32 | UInt64(readUInt32(bytes, offset + 4))
  }
}

private final class StalledLoopbackServer: @unchecked Sendable {
  let port: Int

  private let listener: Int32
  private let release = DispatchSemaphore(value: 0)
  private let hello = DispatchSemaphore(value: 0)
  private let finished = DispatchSemaphore(value: 0)
  private let queue = DispatchQueue(label: "com.kasselvania.pushwig.tests.stalled-reader")

  init() throws {
    let listenerDescriptor = Darwin.socket(AF_INET, SOCK_STREAM, 0)
    guard listenerDescriptor >= 0 else {
      throw ExternalRasterProtocolError.socketFailure("test-listener-create", errno)
    }

    var enabled: Int32 = 1
    guard
      Darwin.setsockopt(
        listenerDescriptor,
        SOL_SOCKET,
        SO_REUSEADDR,
        &enabled,
        socklen_t(MemoryLayout<Int32>.size)
      ) == 0
    else {
      Darwin.close(listenerDescriptor)
      throw ExternalRasterProtocolError.socketFailure("test-listener-reuse", errno)
    }
    var receiveBuffer: Int32 = 1_024
    guard
      Darwin.setsockopt(
        listenerDescriptor,
        SOL_SOCKET,
        SO_RCVBUF,
        &receiveBuffer,
        socklen_t(MemoryLayout<Int32>.size)
      ) == 0
    else {
      Darwin.close(listenerDescriptor)
      throw ExternalRasterProtocolError.socketFailure("test-listener-buffer", errno)
    }

    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = 0
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    let bindResult = withUnsafePointer(to: &address) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.bind(listenerDescriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    guard bindResult == 0, Darwin.listen(listenerDescriptor, 1) == 0 else {
      Darwin.close(listenerDescriptor)
      throw ExternalRasterProtocolError.socketFailure("test-listener-bind", errno)
    }

    var bound = sockaddr_in()
    var boundLength = socklen_t(MemoryLayout<sockaddr_in>.size)
    let nameResult = withUnsafeMutablePointer(to: &bound) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.getsockname(listenerDescriptor, $0, &boundLength)
      }
    }
    guard nameResult == 0 else {
      Darwin.close(listenerDescriptor)
      throw ExternalRasterProtocolError.socketFailure("test-listener-name", errno)
    }
    listener = listenerDescriptor
    port = Int(UInt16(bigEndian: bound.sin_port))

    queue.async { [listenerDescriptor, hello, release, finished] in
      let peer = Darwin.accept(listenerDescriptor, nil, nil)
      guard peer >= 0 else {
        finished.signal()
        return
      }
      defer {
        Darwin.close(peer)
        finished.signal()
      }
      var helloBytes = [UInt8](repeating: 0, count: ProtocolHeaderWriter.headerLength + 32)
      guard readExactly(peer, into: &helloBytes) else { return }
      hello.signal()
      release.wait()
    }
  }

  func waitForHello() -> DispatchTimeoutResult {
    hello.wait(timeout: .now() + 2)
  }

  func stop() {
    release.signal()
    Darwin.shutdown(listener, SHUT_RDWR)
    Darwin.close(listener)
    _ = finished.wait(timeout: .now() + 2)
  }
}

private func makeStalledLoopbackServer() throws -> StalledLoopbackServer {
  try StalledLoopbackServer()
}

private func makeTokenFile() throws -> URL {
  let directory = FileManager.default.temporaryDirectory.appendingPathComponent(
    "pushwig-stalled-reader-\(UUID().uuidString)",
    isDirectory: true
  )
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
  let token = directory.appendingPathComponent("capability")
  try Data((String(repeating: "00", count: 32) + "\n").utf8).write(to: token)
  guard Darwin.chmod(token.path, 0o600) == 0 else {
    throw ExternalRasterProtocolError.invalidTokenFile
  }
  return token
}

private func readExactly(_ descriptor: Int32, into bytes: inout [UInt8]) -> Bool {
  var offset = 0
  while offset < bytes.count {
    let remaining = bytes.count - offset
    let result = bytes.withUnsafeMutableBytes { buffer in
      Darwin.read(descriptor, buffer.baseAddress!.advanced(by: offset), remaining)
    }
    if result > 0 {
      offset += result
    } else if result < 0 && errno == EINTR {
      continue
    } else {
      return false
    }
  }
  return true
}
