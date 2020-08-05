//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/// A class for recognizing long press gesture which notifies a `TriggerDelegate` of the event
@available(iOS 13.0.0, *)
class LongPressGestureRecognizer: NSObject, TriggerRecognizer, UIGestureRecognizerDelegate {

    weak var triggerDelegate: TriggerDelegate?
    weak var uiWindow: UIWindow?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?

    init(uiWindow: UIWindow) {
        super.init()
        self.uiWindow = uiWindow
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self, action: #selector(LongPressGestureRecognizer.longPressed(sender:)))
        registerLongPressRecognizer()
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
        return true
    }

    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            triggerDelegate?.onTrigger(triggerRecognizer: self)
        }
    }

    func updateTriggerDelegate(delegate: TriggerDelegate) {
        triggerDelegate = delegate
    }

    /// Register a `UILongPressGestureRecognizer` to `uiWindow`
    /// to listen to long press events
    private func registerLongPressRecognizer() {
        if longPressGestureRecognizer != nil && uiWindow != nil {
            longPressGestureRecognizer!.delegate = self
            uiWindow!.addGestureRecognizer(longPressGestureRecognizer!)
        }
    }

    /// Unregisters the long press recognizer from `UIWindow`
    func destroy() {
        if longPressGestureRecognizer != nil && uiWindow != nil {
            uiWindow!.removeGestureRecognizer(longPressGestureRecognizer!)
        }

        longPressGestureRecognizer = nil
        uiWindow = nil
        triggerDelegate = nil
    }
}
