#if os(macOS)
import AppKit
import SwiftUI

struct MacTrackpadInputBridge: NSViewRepresentable {
    let invertHorizontalSwipeDirection: Bool
    let onMove: (MoveDirection) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            invertHorizontalSwipeDirection: invertHorizontalSwipeDirection,
            onMove: onMove
        )
    }

    func makeNSView(context: Context) -> InputMonitorView {
        let view = InputMonitorView()
        view.coordinator = context.coordinator
        context.coordinator.attach(to: view)
        return view
    }

    func updateNSView(_ nsView: InputMonitorView, context: Context) {
        context.coordinator.invertHorizontalSwipeDirection = invertHorizontalSwipeDirection
        context.coordinator.onMove = onMove
        context.coordinator.attach(to: nsView)
    }

    static func dismantleNSView(_ nsView: InputMonitorView, coordinator: Coordinator) {
        coordinator.teardown()
    }

    final class InputMonitorView: NSView {
        weak var coordinator: Coordinator?

        override var acceptsFirstResponder: Bool {
            true
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.window?.makeFirstResponder(self)
            }
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            nil
        }
    }

    final class Coordinator {
        var invertHorizontalSwipeDirection: Bool
        var onMove: (MoveDirection) -> Void

        private weak var view: InputMonitorView?
        private var keyMonitor: Any?
        private var scrollMonitor: Any?
        private var accumulatedTranslation: CGSize = .zero
        private var gestureConsumed = false

        init(
            invertHorizontalSwipeDirection: Bool,
            onMove: @escaping (MoveDirection) -> Void
        ) {
            self.invertHorizontalSwipeDirection = invertHorizontalSwipeDirection
            self.onMove = onMove
        }

        func attach(to view: InputMonitorView) {
            self.view = view
            installMonitorsIfNeeded()

            DispatchQueue.main.async { [weak view] in
                view?.window?.makeFirstResponder(view)
            }
        }

        func teardown() {
            if let keyMonitor {
                NSEvent.removeMonitor(keyMonitor)
                self.keyMonitor = nil
            }

            if let scrollMonitor {
                NSEvent.removeMonitor(scrollMonitor)
                self.scrollMonitor = nil
            }

            accumulatedTranslation = .zero
            gestureConsumed = false
        }

        deinit {
            teardown()
        }

        private func installMonitorsIfNeeded() {
            if keyMonitor == nil {
                keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                    self?.handleKeyDown(event) ?? event
                }
            }

            if scrollMonitor == nil {
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
                    self?.handleScrollWheel(event) ?? event
                }
            }
        }

        private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
            guard view?.window?.isKeyWindow == true else { return event }
            guard let direction = direction(for: event) else { return event }

            onMove(direction)
            return nil
        }

        private func handleScrollWheel(_ event: NSEvent) -> NSEvent? {
            guard view?.window?.isKeyWindow == true else { return event }
            guard event.hasPreciseScrollingDeltas else { return event }

            let isTrackpadGesture = !event.phase.isEmpty || !event.momentumPhase.isEmpty
            guard isTrackpadGesture else { return event }

            if event.phase == .began || event.momentumPhase == .began {
                accumulatedTranslation = .zero
                gestureConsumed = false
            }

            if event.phase == .ended || event.phase == .cancelled ||
                event.momentumPhase == .ended || event.momentumPhase == .cancelled {
                accumulatedTranslation = .zero
                gestureConsumed = false
                return nil
            }

            guard !gestureConsumed else { return nil }

            let multiplier: CGFloat = event.isDirectionInvertedFromDevice ? -1 : 1
            accumulatedTranslation.width += CGFloat(event.scrollingDeltaX) * multiplier
            accumulatedTranslation.height += CGFloat(event.scrollingDeltaY) * multiplier

            let threshold: CGFloat = 55

            if abs(accumulatedTranslation.width) > abs(accumulatedTranslation.height),
               abs(accumulatedTranslation.width) >= threshold {
                gestureConsumed = true
                var direction: MoveDirection = accumulatedTranslation.width > 0 ? .left : .right
                if invertHorizontalSwipeDirection {
                    direction = direction == .left ? .right : .left
                }
                onMove(direction)
                return nil
            }

            if abs(accumulatedTranslation.height) >= threshold {
                gestureConsumed = true
                onMove(accumulatedTranslation.height > 0 ? .up : .down)
                return nil
            }

            return nil
        }

        private func direction(for event: NSEvent) -> MoveDirection? {
            switch event.keyCode {
            case 123:
                return .left
            case 124:
                return .right
            case 125:
                return .down
            case 126:
                return .up
            default:
                guard let characters = event.charactersIgnoringModifiers?.lowercased() else {
                    return nil
                }

                switch characters {
                case "a":
                    return .left
                case "d":
                    return .right
                case "s":
                    return .down
                case "w":
                    return .up
                default:
                    return nil
                }
            }
        }
    }
}
#endif
