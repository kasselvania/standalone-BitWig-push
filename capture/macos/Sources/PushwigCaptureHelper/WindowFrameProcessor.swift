// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

enum WindowFrameProcessorError: LocalizedError, Equatable {
  case invalidSourceGeometry
  case unexpectedSourceDimensions
  case invalidDestination
  case renderFailed

  var errorDescription: String? {
    switch self {
    case .invalidSourceGeometry: return "invalid full-window BGRA source geometry"
    case .unexpectedSourceDimensions: return "full-window BGRA source dimensions changed"
    case .invalidDestination: return "window crop destination buffer has the wrong size"
    case .renderFailed: return "window crop did not produce opaque BGRA output"
    }
  }
}

struct FullWindowCaptureSizing: Equatable {
  static let maximumWidthPixels = 2_560
  static let maximumHeightPixels = 1_600
  static let maximumPixels = 4_096_000

  let width: Int
  let height: Int
  let pointToPixelScaleX: Double
  let pointToPixelScaleY: Double

  static func make(contentSizePoints: CGSize, pointPixelScale: Float) throws
    -> FullWindowCaptureSizing
  {
    let pointWidth = Double(contentSizePoints.width)
    let pointHeight = Double(contentSizePoints.height)
    let nativeScale = Double(pointPixelScale)
    guard pointWidth.isFinite, pointHeight.isFinite, nativeScale.isFinite,
      pointWidth > 0, pointHeight > 0, nativeScale > 0
    else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }

    let nativeWidth = pointWidth * nativeScale
    let nativeHeight = pointHeight * nativeScale
    let nativePixels = nativeWidth * nativeHeight
    guard nativeWidth.isFinite, nativeHeight.isFinite, nativePixels.isFinite else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    let pixelLimitScale = sqrt(Double(maximumPixels) / nativePixels)
    let boundedScale = min(
      1,
      Double(maximumWidthPixels) / nativeWidth,
      Double(maximumHeightPixels) / nativeHeight,
      pixelLimitScale
    )
    guard boundedScale.isFinite, boundedScale > 0 else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }

    // Round down so integer output geometry can never cross a memory bound.
    // Both axes use the same pre-rounding scale; the logged X/Y values expose
    // the sub-pixel quantization that remains after integer dimensions.
    let width = max(1, Int((nativeWidth * boundedScale).rounded(.down)))
    let height = max(1, Int((nativeHeight * boundedScale).rounded(.down)))
    guard width <= maximumWidthPixels, height <= maximumHeightPixels,
      width <= maximumPixels / height
    else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }

    return FullWindowCaptureSizing(
      width: width,
      height: height,
      pointToPixelScaleX: Double(width) / pointWidth,
      pointToPixelScaleY: Double(height) / pointHeight
    )
  }
}

struct WindowFramePlan: Equatable {
  let sourceWidth: Int
  let sourceHeight: Int
  let mapping: AspectMapping

  var topLeftPixelCrop: CGRect { mapping.effectiveSourceRect.cgRect }

  var coreImageCrop: CGRect {
    CGRect(
      x: topLeftPixelCrop.minX,
      y: Double(sourceHeight) - topLeftPixelCrop.maxY,
      width: topLeftPixelCrop.width,
      height: topLeftPixelCrop.height
    )
  }

  static func make(
    sourceWidth: Int,
    sourceHeight: Int,
    crop: NormalizedCrop,
    destination: PushDestination
  ) throws -> WindowFramePlan {
    guard sourceWidth > 0, sourceHeight > 0 else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    let requested = try AspectMapping.requestedSourceRect(
      displayWidth: sourceWidth,
      displayHeight: sourceHeight,
      crop: crop
    )
    let mapping = try AspectMapping.centeredCover(
      requestedSourceRect: requested,
      displayWidth: sourceWidth,
      displayHeight: sourceHeight,
      destination: destination
    )
    return WindowFramePlan(
      sourceWidth: sourceWidth,
      sourceHeight: sourceHeight,
      mapping: mapping
    )
  }
}

struct WindowFrameProcessingTiming {
  let pixelBufferAccessNanoseconds: UInt64
  let cropSetupNanoseconds: UInt64
  let scaleRenderNanoseconds: UInt64
  let alphaNormalizationNanoseconds: UInt64
  let sourceBytesPerRow: Int
}

/// Performs the V3 single-window crop explicitly in the helper. ScreenCaptureKit
/// ignores SCStreamConfiguration.sourceRect for desktop-independent single-window
/// capture, so the stream supplies the bounded full window and this object owns
/// the normalized crop and uniform centered-cover scale.
final class WindowFrameProcessor {
  private let destination: PushDestination
  private let context: CIContext

  init(destination: PushDestination) {
    self.destination = destination
    context = CIContext(options: [
      .cacheIntermediates: false,
      .workingColorSpace: NSNull(),
      .outputColorSpace: NSNull(),
    ])
  }

  func render(
    pixelBuffer: CVPixelBuffer,
    plan: WindowFramePlan,
    destinationBytes: inout [UInt8]
  ) throws -> WindowFrameProcessingTiming {
    guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    guard width == plan.sourceWidth, height == plan.sourceHeight else {
      throw WindowFrameProcessorError.unexpectedSourceDimensions
    }
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    guard bytesPerRow >= width * 4 else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    guard destinationBytes.count == destination.payloadBytes else {
      throw WindowFrameProcessorError.invalidDestination
    }

    let accessStart = DispatchTime.now().uptimeNanoseconds
    guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
      throw WindowFrameProcessorError.invalidSourceGeometry
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
    let accessEnd = DispatchTime.now().uptimeNanoseconds

    // Core Image uses a lower-left image coordinate origin. The public profile
    // and CVPixelBuffer rows use top-left coordinates, so WindowFramePlan flips
    // only the crop's Y origin. Edge clamping prevents interpolation from
    // sampling pixels outside the selected profile region.
    let cropStart = accessEnd
    let cropRect = plan.coreImageCrop
    let cropped = CIImage(cvPixelBuffer: pixelBuffer)
      .cropped(to: cropRect)
      .clampedToExtent()
      .transformed(
        by: CGAffineTransform(translationX: -cropRect.minX, y: -cropRect.minY)
      )
    let cropEnd = DispatchTime.now().uptimeNanoseconds

    let scaleStart = cropEnd
    let scaled =
      cropped
      .applyingFilter(
        "CILanczosScaleTransform",
        parameters: [
          kCIInputScaleKey: plan.mapping.uniformScale,
          kCIInputAspectRatioKey: 1.0,
        ]
      )
      .cropped(
        to: CGRect(x: 0, y: 0, width: destination.width, height: destination.height)
      )
    destinationBytes.withUnsafeMutableBytes { output in
      context.render(
        scaled,
        toBitmap: output.baseAddress!,
        rowBytes: destination.stride,
        bounds: CGRect(x: 0, y: 0, width: destination.width, height: destination.height),
        format: .BGRA8,
        colorSpace: nil
      )
    }
    let scaleEnd = DispatchTime.now().uptimeNanoseconds

    let alphaStart = scaleEnd
    destinationBytes.withUnsafeMutableBytes { output in
      let bytes = output.bindMemory(to: UInt8.self)
      var alphaIndex = 3
      while alphaIndex < bytes.count {
        bytes[alphaIndex] = 0xFF
        alphaIndex += 4
      }
    }
    let alphaEnd = DispatchTime.now().uptimeNanoseconds
    guard BGRANormalizer.hasOnlyOpaqueAlpha(destinationBytes) else {
      throw WindowFrameProcessorError.renderFailed
    }

    return WindowFrameProcessingTiming(
      pixelBufferAccessNanoseconds: accessEnd - accessStart,
      cropSetupNanoseconds: cropEnd - cropStart,
      scaleRenderNanoseconds: scaleEnd - scaleStart,
      alphaNormalizationNanoseconds: alphaEnd - alphaStart,
      sourceBytesPerRow: bytesPerRow
    )
  }
}
