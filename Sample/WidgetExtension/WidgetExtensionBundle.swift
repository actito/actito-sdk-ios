//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            CoffeeBrewerLiveActivity()
        }
    }
}
