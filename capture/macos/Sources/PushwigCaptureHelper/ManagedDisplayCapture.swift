// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import Foundation

protocol DisplayOutputManaging: AnyObject {
  func failureDescription() -> String?
  func shutdown() -> String
}

protocol ManagedDisplayCapturing: AnyObject {
  var selectedDisplayFact: DisplayFact { get }
  func start() async throws
  func stop() async
  func updateGuard(_ decision: SourceValidityDecision)
  func captureFailure() -> String?
}

extension CaptureOutputCoordinator: DisplayOutputManaging {}

extension DisplayCropCapture: ManagedDisplayCapturing {
  var selectedDisplayFact: DisplayFact { metadata.displayFact }
}
