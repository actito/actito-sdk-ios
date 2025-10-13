//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct DetermineSize: View {
    internal typealias Key = SizePreferenceKey

    internal var body: some View {
        GeometryReader { proxy in
            Color.clear
                .anchorPreference(key: Key.self, value: .bounds) { anchor in
                    proxy[anchor].size
                }
        }
    }
}

internal struct SizePreferenceKey: PreferenceKey {
    internal static let defaultValue: CGSize = .zero

    internal static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
