// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

import AppKit
import Foundation

@MainActor
final class QuadrantView: NSView {
  private var phase = 0
  private var timer: Timer?

  override var isFlipped: Bool { true }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    timer?.invalidate()
    timer = Timer.scheduledTimer(
      timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance),
      userInfo: nil, repeats: true)
  }

  @objc private func advance() {
    phase = (phase + 3) % max(1, Int(bounds.width) - 40)
    needsDisplay = true
  }

  override func draw(_ dirtyRect: NSRect) {
    let halfWidth = bounds.width / 2
    let halfHeight = bounds.height / 2
    NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: halfWidth, height: halfHeight).fill()
    NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 1).setFill()
    NSRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight).fill()
    NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 1).setFill()
    NSRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight).fill()
    NSColor(calibratedRed: 1, green: 1, blue: 0, alpha: 1).setFill()
    NSRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight).fill()

    NSColor.black.setFill()
    for point in [
      NSPoint(x: 8, y: 8), NSPoint(x: bounds.width - 28, y: 8),
      NSPoint(x: 8, y: bounds.height - 28),
      NSPoint(x: bounds.width - 28, y: bounds.height - 28),
    ] {
      NSRect(origin: point, size: NSSize(width: 20, height: 20)).fill()
    }
    NSColor.white.setFill()
    NSRect(x: CGFloat(phase), y: bounds.midY - 5, width: 40, height: 10).fill()
  }
}

@MainActor
final class FixtureWindow: NSWindow {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}

@MainActor
final class FixtureDelegate: NSObject, NSApplicationDelegate {
  private var window: NSWindow?
  private var lifecycleTimers: [Timer] = []
  private var activationTimer: Timer?
  private let lifecycle = CommandLine.arguments.contains("--lifecycle")

  func applicationDidFinishLaunching(_ notification: Notification) {
    showWindow(frame: initialFrame())
    activationTimer = Timer.scheduledTimer(
      timeInterval: 0.25, target: self, selector: #selector(ensureFrontmost),
      userInfo: nil, repeats: true)
    if lifecycle { scheduleLifecycle() }
  }

  @objc private func ensureFrontmost() {
    window?.makeKeyAndOrderFront(nil)
    NSApp.activate()
  }

  private func initialFrame() -> NSRect {
    guard let screen = NSScreen.main else { return NSRect(x: 40, y: 40, width: 800, height: 600) }
    return NSRect(
      x: screen.frame.minX + 40,
      y: screen.frame.maxY - 640,
      width: 800,
      height: 600
    )
  }

  private func showWindow(frame: NSRect) {
    let window = FixtureWindow(
      contentRect: frame,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.backgroundColor = .black
    window.contentView = QuadrantView(frame: NSRect(origin: .zero, size: frame.size))
    window.collectionBehavior = [.canJoinAllSpaces]
    window.level = .floating
    window.makeKeyAndOrderFront(nil)
    NSApp.activate()
    self.window = window
    printGeometry(event: "OPEN", frame: frame)
  }

  private func scheduleLifecycle() {
    lifecycleTimers.append(
      scheduled(after: 4) { [weak self] in
        guard let self, let window else { return }
        var frame = window.frame
        frame.origin.x += 120
        frame.origin.y -= 80
        window.setFrame(frame, display: true)
        printGeometry(event: "MOVE", frame: frame)
      })
    lifecycleTimers.append(
      scheduled(after: 8) { [weak self] in
        guard let self, let window else { return }
        var frame = window.frame
        frame.size = NSSize(width: 640, height: 480)
        window.setFrame(frame, display: true)
        printGeometry(event: "RESIZE", frame: frame)
      })
    lifecycleTimers.append(
      scheduled(after: 12) { [weak self] in
        self?.window?.orderOut(nil)
        print("FIXTURE event=LOSS")
        fflush(stdout)
      })
    lifecycleTimers.append(
      scheduled(after: 14) { [weak self] in
        self?.showWindow(frame: self?.initialFrame() ?? .zero)
        print("FIXTURE event=RECREATE generation=2")
        fflush(stdout)
      })
  }

  private func scheduled(after seconds: TimeInterval, action: @escaping @MainActor () -> Void)
    -> Timer
  {
    Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
      MainActor.assumeIsolated { action() }
    }
  }

  private func printGeometry(event: String, frame: NSRect) {
    guard let screen = NSScreen.main else { return }
    let top = screen.frame.maxY - frame.maxY
    let normalized = NSRect(
      x: (frame.minX - screen.frame.minX) / screen.frame.width,
      y: top / screen.frame.height,
      width: frame.width / screen.frame.width,
      height: frame.height / screen.frame.height
    )
    print(
      String(
        format: "FIXTURE event=%@ frame_points=%.0f,%.0f,%.0f,%.0f "
          + "display_points=%.0f,%.0f normalized_top_left=%.9f,%.9f,%.9f,%.9f",
        event, frame.minX, frame.minY, frame.width, frame.height,
        screen.frame.width, screen.frame.height,
        normalized.minX, normalized.minY, normalized.width, normalized.height
      )
    )
    fflush(stdout)
  }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = FixtureDelegate()
app.delegate = delegate
app.run()
