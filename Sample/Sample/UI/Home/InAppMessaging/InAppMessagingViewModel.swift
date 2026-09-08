//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoInAppMessagingKit
import ActitoKit
import Foundation

@MainActor
internal class InAppMessagingViewModel: NSObject, ObservableObject {
    @Published internal var hasEvaluateContextOn = false
    @Published internal var hasSuppressedOn = false

    internal func updateSuppressedIamStatus(enabled: Bool) {
        Actito.shared.inAppMessaging().setMessagesSuppressed(enabled, evaluateContext: hasEvaluateContextOn)
    }
}
