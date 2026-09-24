//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct ChipView: View {
    internal let text: String

    internal var body: some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .padding(.vertical, 2)
            .padding([.trailing, .leading], 8)
            .foregroundColor(Color(.label))
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.separator), lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

internal struct ChipView_Previews: PreviewProvider {
    internal static var previews: some View {
        ChipView(
            text: "Foo",
        )
    }
}
