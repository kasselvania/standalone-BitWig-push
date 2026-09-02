// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import Darwin
import Foundation
import Security

struct ProtocolSendTiming {
    let headerPreparationNanoseconds: UInt64
    let socketSendNanoseconds: UInt64
    let sequence: UInt64
}

struct ProtocolClientSnapshot {
    let firstSequence: UInt64?
    let lastSequence: UInt64
    let framesSent: UInt64
    let clearsSent: UInt64
}

enum ExternalRasterProtocolError: LocalizedError {
    case invalidTokenFile
    case randomFailure(OSStatus)
    case socketFailure(String, Int32)
    case sequenceExhausted
    case closed

    var errorDescription: String? {
        switch self {
        case .invalidTokenFile:
            return "capability file is not a private 64...128-byte hexadecimal token file"
        case let .randomFailure(status):
            return "secure session generation failed (status \(status))"
        case let .socketFailure(operation, code):
            return "loopback socket \(operation) failed (errno \(code))"
        case .sequenceExhausted:
            return "protocol sequence exhausted; restart the helper"
        case .closed:
            return "protocol connection is closed"
        }
    }
}

final class ExternalRasterProtocolClient {
    private static let magic: UInt32 = 0x5057_5852
    private static let version: UInt16 = 1
    private static let headerLength: UInt16 = 80
    private static let messageHello: UInt32 = 1
    private static let messageFrame: UInt32 = 2
    private static let messageClear: UInt32 = 3
    private static let formatNone: UInt32 = 0
    private static let formatOpaqueBGRA: UInt32 = 1
    private static let tokenBytes = 32
    private static let tokenHexBytes = tokenBytes * 2
    private static let maximumTokenFileBytes = 128

    private var socketDescriptor: Int32 = -1
    private var capability: [UInt8]
    private var header = [UInt8](repeating: 0, count: Int(headerLength))
    private let sessionHigh: UInt64
    private let sessionLow: UInt64
    private var sequence: UInt64 = 0
    private(set) var visualAuthority = false
    private var firstFrameSequence: UInt64?
    private var framesSent: UInt64 = 0
    private var clearsSent: UInt64 = 0

    init(port: Int, tokenFile: URL) throws {
        capability = try Self.loadCapability(from: tokenFile)
        let session = try Self.makeSession()
        sessionHigh = session.0
        sessionLow = session.1

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
        guard pixels.count == destination.payloadBytes else {
            throw CaptureConfigurationError.invalid("output buffer does not match destination geometry")
        }

        let next = try nextSequence()
        let headerStart = DispatchTime.now().uptimeNanoseconds
        prepareHeader(
            messageType: Self.messageFrame,
            format: Self.formatOpaqueBGRA,
            sequence: next,
            destinationX: UInt32(destination.x),
            destinationY: UInt32(destination.y),
            width: UInt32(destination.width),
            height: UInt32(destination.height),
            stride: UInt32(destination.stride),
            payloadLength: UInt32(destination.payloadBytes)
        )
        let headerEnd = DispatchTime.now().uptimeNanoseconds

        let sendStart = headerEnd
        do {
            try header.withUnsafeBytes(writeAll)
            try pixels.withUnsafeBytes(writeAll)
        } catch {
            close()
            throw error
        }
        let sendEnd = DispatchTime.now().uptimeNanoseconds

        sequence = next
        visualAuthority = true
        framesSent += 1
        if firstFrameSequence == nil { firstFrameSequence = next }
        return ProtocolSendTiming(
            headerPreparationNanoseconds: headerEnd - headerStart,
            socketSendNanoseconds: sendEnd - sendStart,
            sequence: next
        )
    }

    @discardableResult
    func sendClearIfNeeded() throws -> ProtocolSendTiming? {
        guard visualAuthority else { return nil }
        guard socketDescriptor >= 0 else { throw ExternalRasterProtocolError.closed }

        let next = try nextSequence()
        let headerStart = DispatchTime.now().uptimeNanoseconds
        prepareHeader(
            messageType: Self.messageClear,
            format: Self.formatNone,
            sequence: next,
            destinationX: 0,
            destinationY: 0,
            width: 0,
            height: 0,
            stride: 0,
            payloadLength: 0
        )
        let headerEnd = DispatchTime.now().uptimeNanoseconds

        let sendStart = headerEnd
        do {
            try header.withUnsafeBytes(writeAll)
        } catch {
            close()
            throw error
        }
        let sendEnd = DispatchTime.now().uptimeNanoseconds

        sequence = next
        visualAuthority = false
        clearsSent += 1
        return ProtocolSendTiming(
            headerPreparationNanoseconds: headerEnd - headerStart,
            socketSendNanoseconds: sendEnd - sendStart,
            sequence: next
        )
    }

    func snapshot() -> ProtocolClientSnapshot {
        ProtocolClientSnapshot(
            firstSequence: firstFrameSequence,
            lastSequence: sequence,
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
        prepareHeader(
            messageType: Self.messageHello,
            format: Self.formatNone,
            sequence: 0,
            destinationX: 0,
            destinationY: 0,
            width: 0,
            height: 0,
            stride: 0,
            payloadLength: UInt32(Self.tokenBytes)
        )
        do {
            try header.withUnsafeBytes(writeAll)
            try capability.withUnsafeBytes(writeAll)
        } catch {
            close()
            throw error
        }
    }

    private func nextSequence() throws -> UInt64 {
        let maximum = UInt64(Int64.max)
        guard sequence < maximum else { throw ExternalRasterProtocolError.sequenceExhausted }
        return sequence + 1
    }

    private func prepareHeader(
        messageType: UInt32,
        format: UInt32,
        sequence: UInt64,
        destinationX: UInt32,
        destinationY: UInt32,
        width: UInt32,
        height: UInt32,
        stride: UInt32,
        payloadLength: UInt32
    ) {
        _ = header.withUnsafeMutableBytes { bytes in
            bytes.initializeMemory(as: UInt8.self, repeating: 0)
        }
        putUInt32(Self.magic, at: 0)
        putUInt16(Self.version, at: 4)
        putUInt16(Self.headerLength, at: 6)
        putUInt32(messageType, at: 8)
        putUInt32(format, at: 16)
        putUInt64(sessionHigh, at: 24)
        putUInt64(sessionLow, at: 32)
        putUInt64(sequence, at: 40)
        putUInt32(destinationX, at: 48)
        putUInt32(destinationY, at: 52)
        putUInt32(width, at: 56)
        putUInt32(height, at: 60)
        putUInt32(stride, at: 64)
        putUInt32(payloadLength, at: 68)
    }

    private func putUInt16(_ value: UInt16, at offset: Int) {
        header[offset] = UInt8(truncatingIfNeeded: value >> 8)
        header[offset + 1] = UInt8(truncatingIfNeeded: value)
    }

    private func putUInt32(_ value: UInt32, at offset: Int) {
        header[offset] = UInt8(truncatingIfNeeded: value >> 24)
        header[offset + 1] = UInt8(truncatingIfNeeded: value >> 16)
        header[offset + 2] = UInt8(truncatingIfNeeded: value >> 8)
        header[offset + 3] = UInt8(truncatingIfNeeded: value)
    }

    private func putUInt64(_ value: UInt64, at offset: Int) {
        putUInt32(UInt32(truncatingIfNeeded: value >> 32), at: offset)
        putUInt32(UInt32(truncatingIfNeeded: value), at: offset + 4)
    }

    private func writeAll(_ bytes: UnsafeRawBufferPointer) throws {
        guard socketDescriptor >= 0 else { throw ExternalRasterProtocolError.closed }
        guard let baseAddress = bytes.baseAddress else { return }
        var written = 0
        while written < bytes.count {
            let count = Darwin.send(
                socketDescriptor,
                baseAddress.advanced(by: written),
                bytes.count - written,
                0
            )
            if count > 0 {
                written += count
                continue
            }
            if count < 0 && errno == EINTR { continue }
            throw ExternalRasterProtocolError.socketFailure("send", errno)
        }
    }

    private static func connectLoopback(port: Int) throws -> Int32 {
        let descriptor = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        guard descriptor >= 0 else {
            throw ExternalRasterProtocolError.socketFailure("create", errno)
        }

        do {
            var enabled: Int32 = 1
            guard Darwin.setsockopt(
                descriptor,
                SOL_SOCKET,
                SO_NOSIGPIPE,
                &enabled,
                socklen_t(MemoryLayout<Int32>.size)
            ) == 0 else {
                throw ExternalRasterProtocolError.socketFailure("SO_NOSIGPIPE", errno)
            }
            guard Darwin.setsockopt(
                descriptor,
                IPPROTO_TCP,
                TCP_NODELAY,
                &enabled,
                socklen_t(MemoryLayout<Int32>.size)
            ) == 0 else {
                throw ExternalRasterProtocolError.socketFailure("TCP_NODELAY", errno)
            }

            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = in_port_t(port).bigEndian
            address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

            let result = withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.connect(descriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            guard result == 0 else {
                throw ExternalRasterProtocolError.socketFailure("connect", errno)
            }
            return descriptor
        } catch {
            Darwin.close(descriptor)
            throw error
        }
    }

    private static func makeSession() throws -> (UInt64, UInt64) {
        var bytes = [UInt8](repeating: 0, count: 16)
        let status = bytes.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
        }
        guard status == errSecSuccess else {
            throw ExternalRasterProtocolError.randomFailure(status)
        }
        var high: UInt64 = 0
        var low: UInt64 = 0
        for index in 0 ..< 8 { high = high << 8 | UInt64(bytes[index]) }
        for index in 8 ..< 16 { low = low << 8 | UInt64(bytes[index]) }
        _ = bytes.withUnsafeMutableBytes { buffer in
            buffer.initializeMemory(as: UInt8.self, repeating: 0)
        }
        if high == 0 && low == 0 { low = 1 }
        return (high, low)
    }

    private static func loadCapability(from url: URL) throws -> [UInt8] {
        let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW)
        guard descriptor >= 0 else { throw ExternalRasterProtocolError.invalidTokenFile }
        defer { Darwin.close(descriptor) }

        var status = stat()
        guard Darwin.fstat(descriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFREG,
              status.st_uid == getuid(),
              status.st_mode & 0o077 == 0,
              status.st_size >= tokenHexBytes,
              status.st_size <= maximumTokenFileBytes else {
            throw ExternalRasterProtocolError.invalidTokenFile
        }

        let length = Int(status.st_size)
        var fileBytes = [UInt8](repeating: 0, count: maximumTokenFileBytes)
        defer {
            _ = fileBytes.withUnsafeMutableBytes { buffer in
                buffer.initializeMemory(as: UInt8.self, repeating: 0)
            }
        }

        var received = 0
        while received < length {
            let count = fileBytes.withUnsafeMutableBytes { buffer in
                Darwin.read(descriptor, buffer.baseAddress!.advanced(by: received), length - received)
            }
            if count > 0 {
                received += count
                continue
            }
            if count < 0 && errno == EINTR { continue }
            throw ExternalRasterProtocolError.invalidTokenFile
        }

        var token = [UInt8](repeating: 0, count: tokenBytes)
        for index in 0 ..< tokenBytes {
            guard let high = hexadecimal(fileBytes[index * 2]),
                  let low = hexadecimal(fileBytes[index * 2 + 1]) else {
                _ = token.withUnsafeMutableBytes { buffer in
                    buffer.initializeMemory(as: UInt8.self, repeating: 0)
                }
                throw ExternalRasterProtocolError.invalidTokenFile
            }
            token[index] = high << 4 | low
        }
        for byte in fileBytes[tokenHexBytes ..< length] where !isASCIIWhitespace(byte) {
            _ = token.withUnsafeMutableBytes { buffer in
                buffer.initializeMemory(as: UInt8.self, repeating: 0)
            }
            throw ExternalRasterProtocolError.invalidTokenFile
        }
        return token
    }

    private static func hexadecimal(_ byte: UInt8) -> UInt8? {
        switch byte {
        case 48 ... 57: return byte - 48
        case 65 ... 70: return byte - 65 + 10
        case 97 ... 102: return byte - 97 + 10
        default: return nil
        }
    }

    private static func isASCIIWhitespace(_ byte: UInt8) -> Bool {
        byte == 32 || (9 ... 13).contains(byte)
    }
}
