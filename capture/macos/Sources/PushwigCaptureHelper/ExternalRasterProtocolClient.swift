// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import Darwin
import Foundation
import Security

enum ExternalRasterProtocolError: LocalizedError {
  case invalidTokenFile
  case randomFailure(OSStatus)
  case socketFailure(String, Int32)
  case writeDeadlineExceeded(Int)
  case sequenceExhausted
  case closed

  var errorDescription: String? {
    switch self {
    case .invalidTokenFile:
      return "capability file must be a private 64...128-byte hexadecimal token file"
    case .randomFailure(let status):
      return "secure session generation failed (status \(status))"
    case .socketFailure(let operation, let code):
      return "loopback socket \(operation) failed (errno \(code))"
    case .writeDeadlineExceeded(let milliseconds):
      return "loopback socket write exceeded fixed \(milliseconds) ms deadline"
    case .sequenceExhausted:
      return "protocol sequence exhausted; restart the helper"
    case .closed:
      return "protocol connection is closed"
    }
  }
}

struct ProtocolSendTiming {
  let headerPreparationNanoseconds: UInt64
  let socketSendNanoseconds: UInt64
  let sequence: UInt64
}

struct ProtocolClientSnapshot {
  let firstFrameSequence: UInt64?
  let lastSequence: UInt64
  let framesSent: UInt64
  let clearsSent: UInt64
}

struct ProtocolSequence: Equatable {
  private(set) var current: UInt64 = 0

  mutating func next() throws -> UInt64 {
    guard current < UInt64(Int64.max) else {
      throw ExternalRasterProtocolError.sequenceExhausted
    }
    current += 1
    return current
  }
}

enum ProtocolHeaderWriter {
  static let magic: UInt32 = 0x5057_5852
  static let version: UInt16 = 1
  static let headerLength = 80
  static let messageHello: UInt32 = 1
  static let messageFrame: UInt32 = 2
  static let messageClear: UInt32 = 3
  static let formatNone: UInt32 = 0
  static let formatOpaqueBGRA: UInt32 = 1
  static let maximumPayloadBytes = 614_400

  static func write(
    into header: inout [UInt8],
    messageType: UInt32,
    format: UInt32,
    sessionHigh: UInt64,
    sessionLow: UInt64,
    sequence: UInt64,
    destinationX: UInt32,
    destinationY: UInt32,
    width: UInt32,
    height: UInt32,
    stride: UInt32,
    payloadLength: UInt32
  ) {
    precondition(header.count == headerLength)
    _ = header.withUnsafeMutableBytes { bytes in
      bytes.initializeMemory(as: UInt8.self, repeating: 0)
    }
    putUInt32(magic, into: &header, at: 0)
    putUInt16(version, into: &header, at: 4)
    putUInt16(UInt16(headerLength), into: &header, at: 6)
    putUInt32(messageType, into: &header, at: 8)
    putUInt32(format, into: &header, at: 16)
    putUInt64(sessionHigh, into: &header, at: 24)
    putUInt64(sessionLow, into: &header, at: 32)
    putUInt64(sequence, into: &header, at: 40)
    putUInt32(destinationX, into: &header, at: 48)
    putUInt32(destinationY, into: &header, at: 52)
    putUInt32(width, into: &header, at: 56)
    putUInt32(height, into: &header, at: 60)
    putUInt32(stride, into: &header, at: 64)
    putUInt32(payloadLength, into: &header, at: 68)
  }

  private static func putUInt16(_ value: UInt16, into bytes: inout [UInt8], at offset: Int) {
    bytes[offset] = UInt8(truncatingIfNeeded: value >> 8)
    bytes[offset + 1] = UInt8(truncatingIfNeeded: value)
  }

  private static func putUInt32(_ value: UInt32, into bytes: inout [UInt8], at offset: Int) {
    bytes[offset] = UInt8(truncatingIfNeeded: value >> 24)
    bytes[offset + 1] = UInt8(truncatingIfNeeded: value >> 16)
    bytes[offset + 2] = UInt8(truncatingIfNeeded: value >> 8)
    bytes[offset + 3] = UInt8(truncatingIfNeeded: value)
  }

  private static func putUInt64(_ value: UInt64, into bytes: inout [UInt8], at offset: Int) {
    putUInt32(UInt32(truncatingIfNeeded: value >> 32), into: &bytes, at: offset)
    putUInt32(UInt32(truncatingIfNeeded: value), into: &bytes, at: offset + 4)
  }
}

final class ExternalRasterProtocolClient {
  // One deadline covers the complete HELLO, FRAME, or CLEAR message. Normal
  // loopback sends are sub-millisecond; 250 ms bounds a stalled peer without
  // introducing a retry queue or another thread.
  static let writeDeadlineMilliseconds = 250

  private static let tokenBytes = 32
  private static let tokenHexBytes = tokenBytes * 2
  private static let maximumTokenFileBytes = 128

  private var socketDescriptor: Int32 = -1
  private var capability: [UInt8]
  private var header = [UInt8](repeating: 0, count: ProtocolHeaderWriter.headerLength)
  private let sessionHigh: UInt64
  private let sessionLow: UInt64
  private var protocolSequence = ProtocolSequence()
  private(set) var visualAuthority = false
  private var firstFrameSequence: UInt64?
  private var framesSent: UInt64 = 0
  private var clearsSent: UInt64 = 0

  init(port: Int, tokenFile: URL) throws {
    capability = try Self.loadCapability(from: tokenFile)
    let session = try Self.makeSession()
    sessionHigh = session.high
    sessionLow = session.low

    do {
      socketDescriptor = try Self.connectLoopback(port: port)
      try sendHello()
    } catch {
      close()
      throw error
    }
  }

  deinit {
    close()
  }

  func sendFrame(destination: PushDestination, pixels: [UInt8]) throws -> ProtocolSendTiming {
    guard socketDescriptor >= 0 else { throw ExternalRasterProtocolError.closed }
    guard pixels.count == destination.payloadBytes,
      pixels.count <= ProtocolHeaderWriter.maximumPayloadBytes
    else {
      throw CaptureConfigurationError.invalid(
        "output buffer does not match bounded destination geometry"
      )
    }

    let next = try protocolSequence.next()
    let headerStart = DispatchTime.now().uptimeNanoseconds
    ProtocolHeaderWriter.write(
      into: &header,
      messageType: ProtocolHeaderWriter.messageFrame,
      format: ProtocolHeaderWriter.formatOpaqueBGRA,
      sessionHigh: sessionHigh,
      sessionLow: sessionLow,
      sequence: next,
      destinationX: UInt32(destination.x),
      destinationY: UInt32(destination.y),
      width: UInt32(destination.width),
      height: UInt32(destination.height),
      stride: UInt32(destination.stride),
      payloadLength: UInt32(destination.payloadBytes)
    )
    let headerEnd = DispatchTime.now().uptimeNanoseconds

    do {
      let deadline = Self.makeWriteDeadline()
      try header.withUnsafeBytes { try writeAll($0, deadline: deadline) }
      try pixels.withUnsafeBytes { try writeAll($0, deadline: deadline) }
    } catch {
      close()
      throw error
    }
    let sendEnd = DispatchTime.now().uptimeNanoseconds

    visualAuthority = true
    framesSent += 1
    if firstFrameSequence == nil { firstFrameSequence = next }
    return ProtocolSendTiming(
      headerPreparationNanoseconds: headerEnd - headerStart,
      socketSendNanoseconds: sendEnd - headerEnd,
      sequence: next
    )
  }

  @discardableResult
  func sendClearIfNeeded() throws -> ProtocolSendTiming? {
    guard visualAuthority else { return nil }
    guard socketDescriptor >= 0 else { throw ExternalRasterProtocolError.closed }

    let next = try protocolSequence.next()
    let headerStart = DispatchTime.now().uptimeNanoseconds
    ProtocolHeaderWriter.write(
      into: &header,
      messageType: ProtocolHeaderWriter.messageClear,
      format: ProtocolHeaderWriter.formatNone,
      sessionHigh: sessionHigh,
      sessionLow: sessionLow,
      sequence: next,
      destinationX: 0,
      destinationY: 0,
      width: 0,
      height: 0,
      stride: 0,
      payloadLength: 0
    )
    let headerEnd = DispatchTime.now().uptimeNanoseconds

    do {
      let deadline = Self.makeWriteDeadline()
      try header.withUnsafeBytes { try writeAll($0, deadline: deadline) }
    } catch {
      close()
      throw error
    }
    let sendEnd = DispatchTime.now().uptimeNanoseconds

    visualAuthority = false
    clearsSent += 1
    return ProtocolSendTiming(
      headerPreparationNanoseconds: headerEnd - headerStart,
      socketSendNanoseconds: sendEnd - headerEnd,
      sequence: next
    )
  }

  func snapshot() -> ProtocolClientSnapshot {
    ProtocolClientSnapshot(
      firstFrameSequence: firstFrameSequence,
      lastSequence: protocolSequence.current,
      framesSent: framesSent,
      clearsSent: clearsSent
    )
  }

  func close() {
    if socketDescriptor >= 0 {
      Darwin.shutdown(socketDescriptor, SHUT_RDWR)
      Darwin.close(socketDescriptor)
      socketDescriptor = -1
    }
    visualAuthority = false
    _ = capability.withUnsafeMutableBytes { bytes in
      bytes.initializeMemory(as: UInt8.self, repeating: 0)
    }
    _ = header.withUnsafeMutableBytes { bytes in
      bytes.initializeMemory(as: UInt8.self, repeating: 0)
    }
  }

  private func sendHello() throws {
    ProtocolHeaderWriter.write(
      into: &header,
      messageType: ProtocolHeaderWriter.messageHello,
      format: ProtocolHeaderWriter.formatNone,
      sessionHigh: sessionHigh,
      sessionLow: sessionLow,
      sequence: 0,
      destinationX: 0,
      destinationY: 0,
      width: 0,
      height: 0,
      stride: 0,
      payloadLength: UInt32(Self.tokenBytes)
    )
    do {
      let deadline = Self.makeWriteDeadline()
      try header.withUnsafeBytes { try writeAll($0, deadline: deadline) }
      try capability.withUnsafeBytes { try writeAll($0, deadline: deadline) }
    } catch {
      close()
      throw error
    }
  }

  private func writeAll(
    _ bytes: UnsafeRawBufferPointer,
    deadline: UInt64
  ) throws {
    guard socketDescriptor >= 0 else { throw ExternalRasterProtocolError.closed }
    guard let baseAddress = bytes.baseAddress else { return }
    var written = 0
    while written < bytes.count {
      try Self.requireValidWriteDeadline(deadline)
      let result = Darwin.send(
        socketDescriptor,
        baseAddress.advanced(by: written),
        bytes.count - written,
        0
      )
      if result > 0 {
        written += result
      } else if result < 0 {
        let code = errno
        if code == EINTR {
          try Self.requireValidWriteDeadline(deadline)
          continue
        }
        if code == EAGAIN || code == EWOULDBLOCK {
          try waitUntilWritable(deadline: deadline)
          continue
        }
        throw ExternalRasterProtocolError.socketFailure("send", code)
      } else {
        throw ExternalRasterProtocolError.socketFailure("send", EPIPE)
      }
    }
  }

  private func waitUntilWritable(deadline: UInt64) throws {
    while true {
      let timeout = try Self.remainingPollMilliseconds(deadline: deadline)
      var descriptor = pollfd(fd: socketDescriptor, events: Int16(POLLOUT), revents: 0)
      let result = Darwin.poll(&descriptor, 1, timeout)
      if result > 0 {
        if descriptor.revents & Int16(POLLOUT) != 0 { return }
        if descriptor.revents & Int16(POLLERR | POLLHUP | POLLNVAL) != 0 {
          throw ExternalRasterProtocolError.socketFailure(
            "poll",
            socketError(descriptor: socketDescriptor)
          )
        }
      } else if result == 0 {
        throw ExternalRasterProtocolError.writeDeadlineExceeded(
          Self.writeDeadlineMilliseconds
        )
      } else {
        let code = errno
        if code == EINTR {
          try Self.requireValidWriteDeadline(deadline)
          continue
        }
        throw ExternalRasterProtocolError.socketFailure("poll", code)
      }
    }
  }

  private func socketError(descriptor: Int32) -> Int32 {
    var code: Int32 = 0
    var length = socklen_t(MemoryLayout<Int32>.size)
    guard Darwin.getsockopt(descriptor, SOL_SOCKET, SO_ERROR, &code, &length) == 0,
      code != 0
    else {
      return EPIPE
    }
    return code
  }

  private static func makeWriteDeadline() -> UInt64 {
    let now = DispatchTime.now().uptimeNanoseconds
    let duration = UInt64(writeDeadlineMilliseconds) * 1_000_000
    let (deadline, overflow) = now.addingReportingOverflow(duration)
    return overflow ? UInt64.max : deadline
  }

  private static func requireValidWriteDeadline(_ deadline: UInt64) throws {
    guard DispatchTime.now().uptimeNanoseconds < deadline else {
      throw ExternalRasterProtocolError.writeDeadlineExceeded(writeDeadlineMilliseconds)
    }
  }

  private static func remainingPollMilliseconds(deadline: UInt64) throws -> Int32 {
    let now = DispatchTime.now().uptimeNanoseconds
    guard now < deadline else {
      throw ExternalRasterProtocolError.writeDeadlineExceeded(writeDeadlineMilliseconds)
    }
    let remainingNanoseconds = deadline - now
    let wholeMilliseconds = remainingNanoseconds / 1_000_000
    let roundedUp = wholeMilliseconds + (remainingNanoseconds % 1_000_000 == 0 ? 0 : 1)
    return Int32(min(roundedUp, UInt64(Int32.max)))
  }

  private static func connectLoopback(port: Int) throws -> Int32 {
    let descriptor = Darwin.socket(AF_INET, SOCK_STREAM, 0)
    guard descriptor >= 0 else {
      throw ExternalRasterProtocolError.socketFailure("create", errno)
    }

    do {
      var enabled: Int32 = 1
      guard
        Darwin.setsockopt(
          descriptor,
          SOL_SOCKET,
          SO_NOSIGPIPE,
          &enabled,
          socklen_t(MemoryLayout<Int32>.size)
        ) == 0
      else {
        throw ExternalRasterProtocolError.socketFailure("SO_NOSIGPIPE", errno)
      }
      guard
        Darwin.setsockopt(
          descriptor,
          IPPROTO_TCP,
          TCP_NODELAY,
          &enabled,
          socklen_t(MemoryLayout<Int32>.size)
        ) == 0
      else {
        throw ExternalRasterProtocolError.socketFailure("TCP_NODELAY", errno)
      }

      var address = sockaddr_in()
      address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
      address.sin_family = sa_family_t(AF_INET)
      address.sin_port = in_port_t(port).bigEndian
      address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

      let result = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
          Darwin.connect(
            descriptor,
            $0,
            socklen_t(MemoryLayout<sockaddr_in>.size)
          )
        }
      }
      guard result == 0 else {
        throw ExternalRasterProtocolError.socketFailure("connect", errno)
      }
      let flags = Darwin.fcntl(descriptor, F_GETFL)
      guard flags >= 0 else {
        throw ExternalRasterProtocolError.socketFailure("F_GETFL", errno)
      }
      guard Darwin.fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0 else {
        throw ExternalRasterProtocolError.socketFailure("O_NONBLOCK", errno)
      }
      return descriptor
    } catch {
      Darwin.close(descriptor)
      throw error
    }
  }

  private static func makeSession() throws -> (high: UInt64, low: UInt64) {
    var bytes = [UInt8](repeating: 0, count: 16)
    defer {
      _ = bytes.withUnsafeMutableBytes { buffer in
        buffer.initializeMemory(as: UInt8.self, repeating: 0)
      }
    }
    let status = bytes.withUnsafeMutableBytes { buffer in
      SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
    }
    guard status == errSecSuccess else {
      throw ExternalRasterProtocolError.randomFailure(status)
    }

    var high: UInt64 = 0
    var low: UInt64 = 0
    for index in 0..<8 { high = high << 8 | UInt64(bytes[index]) }
    for index in 8..<16 { low = low << 8 | UInt64(bytes[index]) }
    if high == 0 && low == 0 { low = 1 }
    return (high, low)
  }

  private static func loadCapability(from url: URL) throws -> [UInt8] {
    let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW)
    guard descriptor >= 0 else { throw ExternalRasterProtocolError.invalidTokenFile }
    defer { Darwin.close(descriptor) }

    var metadata = stat()
    guard Darwin.fstat(descriptor, &metadata) == 0,
      metadata.st_mode & S_IFMT == S_IFREG,
      metadata.st_uid == getuid(),
      metadata.st_mode & 0o077 == 0,
      metadata.st_size >= tokenHexBytes,
      metadata.st_size <= maximumTokenFileBytes
    else {
      throw ExternalRasterProtocolError.invalidTokenFile
    }

    let length = Int(metadata.st_size)
    var fileBytes = [UInt8](repeating: 0, count: maximumTokenFileBytes)
    defer {
      _ = fileBytes.withUnsafeMutableBytes { bytes in
        bytes.initializeMemory(as: UInt8.self, repeating: 0)
      }
    }
    var received = 0
    while received < length {
      let result = fileBytes.withUnsafeMutableBytes { bytes in
        Darwin.read(
          descriptor,
          bytes.baseAddress!.advanced(by: received),
          length - received
        )
      }
      if result > 0 {
        received += result
      } else if result < 0 && errno == EINTR {
        continue
      } else {
        throw ExternalRasterProtocolError.invalidTokenFile
      }
    }

    var capability = [UInt8](repeating: 0, count: tokenBytes)
    do {
      for index in 0..<tokenBytes {
        guard let high = hexadecimal(fileBytes[index * 2]),
          let low = hexadecimal(fileBytes[index * 2 + 1])
        else {
          throw ExternalRasterProtocolError.invalidTokenFile
        }
        capability[index] = high << 4 | low
      }
      for byte in fileBytes[tokenHexBytes..<length] where !isASCIIWhitespace(byte) {
        throw ExternalRasterProtocolError.invalidTokenFile
      }
    } catch {
      _ = capability.withUnsafeMutableBytes { bytes in
        bytes.initializeMemory(as: UInt8.self, repeating: 0)
      }
      throw error
    }
    return capability
  }

  private static func hexadecimal(_ byte: UInt8) -> UInt8? {
    switch byte {
    case 48...57: return byte - 48
    case 65...70: return byte - 65 + 10
    case 97...102: return byte - 97 + 10
    default: return nil
    }
  }

  private static func isASCIIWhitespace(_ byte: UInt8) -> Bool {
    byte == 32 || (9...13).contains(byte)
  }
}
