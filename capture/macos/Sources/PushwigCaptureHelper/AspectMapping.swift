// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import CoreGraphics
import Foundation

struct ScreenPointRect: Equatable, CustomStringConvertible {
  let x: Double
  let y: Double
  let width: Double
  let height: Double

  var cgRect: CGRect {
    CGRect(x: x, y: y, width: width, height: height)
  }

  var description: String {
    String(format: "%.6f,%.6f,%.6f,%.6f", x, y, width, height)
  }
}

struct AspectMapping: Equatable {
  enum Policy: String {
    case centeredCover = "centered-cover"
  }

  let policy: Policy
  let requestedSourceRect: CGRect
  let effectiveSourceRect: ScreenPointRect
  let destination: PushDestination
  let uniformScale: Double
  let croppedLeft: Double
  let croppedTop: Double
  let croppedRight: Double
  let croppedBottom: Double

  var requestedSourceAspect: Double {
    requestedSourceRect.width / requestedSourceRect.height
  }

  var effectiveSourceAspect: Double {
    effectiveSourceRect.width / effectiveSourceRect.height
  }

  var destinationAspect: Double {
    Double(destination.width) / Double(destination.height)
  }

  static func centeredCover(
    displayWidth: Int,
    displayHeight: Int,
    crop: NormalizedCrop,
    destination: PushDestination
  ) throws -> AspectMapping {
    let requested = try requestedSourceRect(
      displayWidth: displayWidth,
      displayHeight: displayHeight,
      crop: crop
    )
    return try centeredCover(
      requestedSourceRect: requested,
      displayWidth: displayWidth,
      displayHeight: displayHeight,
      destination: destination
    )
  }

  static func requestedSourceRect(
    displayWidth: Int,
    displayHeight: Int,
    crop: NormalizedCrop
  ) throws -> CGRect {
    guard displayWidth > 0, displayHeight > 0 else {
      throw CaptureConfigurationError.invalid("display point dimensions must be positive")
    }

    let displayWidthDouble = Double(displayWidth)
    let displayHeightDouble = Double(displayHeight)
    let requested = CGRect(
      x: crop.x * displayWidthDouble,
      y: crop.y * displayHeightDouble,
      width: crop.width * displayWidthDouble,
      height: crop.height * displayHeightDouble
    )
    guard requested.minX.isFinite, requested.minY.isFinite,
      requested.width.isFinite, requested.height.isFinite,
      requested.minX >= 0, requested.minY >= 0,
      requested.maxX <= displayWidthDouble,
      requested.maxY <= displayHeightDouble
    else {
      throw CaptureConfigurationError.invalid("computed source crop is outside the display")
    }
    return requested
  }

  static func centeredCover(
    requestedSourceRect requested: CGRect,
    displayWidth: Int,
    displayHeight: Int,
    destination: PushDestination
  ) throws -> AspectMapping {
    guard requested.minX.isFinite, requested.minY.isFinite,
      requested.width.isFinite, requested.height.isFinite,
      requested.width > 0, requested.height > 0,
      requested.minX >= 0, requested.minY >= 0,
      requested.maxX <= Double(displayWidth),
      requested.maxY <= Double(displayHeight)
    else {
      throw CaptureConfigurationError.invalid("requested source crop is outside the display")
    }
    // ScreenCaptureKit source rectangles are expressed in screen points and
    // accept fractional CGRect geometry. Keep the maximal centered cover
    // instead of quantizing it to integer multiples of the destination ratio.
    let destinationAspect = Double(destination.width) / Double(destination.height)
    let requestedAspect = requested.width / requested.height
    let effectiveWidth: Double
    let effectiveHeight: Double
    if requestedAspect > destinationAspect {
      effectiveHeight = requested.height
      effectiveWidth = effectiveHeight * destinationAspect
    } else {
      effectiveWidth = requested.width
      effectiveHeight = effectiveWidth / destinationAspect
    }
    guard effectiveWidth.isFinite, effectiveHeight.isFinite,
      effectiveWidth > 0, effectiveHeight > 0,
      effectiveWidth <= requested.width, effectiveHeight <= requested.height
    else {
      throw CaptureConfigurationError.invalid(
        "no maximal aspect-preserving source rectangle fits inside the crop"
      )
    }

    let effective = ScreenPointRect(
      x: requested.minX + (requested.width - effectiveWidth) / 2,
      y: requested.minY + (requested.height - effectiveHeight) / 2,
      width: effectiveWidth,
      height: effectiveHeight
    )

    guard effective.x.isFinite, effective.y.isFinite,
      effective.x >= requested.minX, effective.y >= requested.minY,
      effective.width <= requested.maxX - effective.x,
      effective.height <= requested.maxY - effective.y,
      effective.x >= 0, effective.y >= 0,
      effective.width <= Double(displayWidth) - effective.x,
      effective.height <= Double(displayHeight) - effective.y
    else {
      throw CaptureConfigurationError.invalid(
        "aspect-preserving source rectangle is outside the display point bounds"
      )
    }

    let scaleX = Double(destination.width) / effective.width
    let scaleY = Double(destination.height) / effective.height
    guard abs(scaleX - scaleY) <= 1e-12 * max(scaleX, scaleY) else {
      throw CaptureConfigurationError.invalid("aspect mapping did not produce one uniform scale")
    }

    return AspectMapping(
      policy: .centeredCover,
      requestedSourceRect: requested,
      effectiveSourceRect: effective,
      destination: destination,
      uniformScale: scaleX,
      croppedLeft: effective.x - requested.minX,
      croppedTop: effective.y - requested.minY,
      croppedRight: requested.maxX - (effective.x + effective.width),
      croppedBottom: requested.maxY - (effective.y + effective.height)
    )
  }
}
