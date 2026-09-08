//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct PreferredLanguageSection: View {
    @State internal var language: String = ""

    internal let hasPreferredLanguage: Bool
    internal let updatePreferredLanguage: (String) -> Void
    internal let clearPreferredLanguage: () -> Void

    internal var body: some View {
        Section {
            TextField(String(localized: "device_preferred_language_language"), text: $language)
                .autocorrectionDisabled()
                .autocapitalization(.none)

            Button(String(localized: "device_preferred_language_button")) {
                updatePreferredLanguage(language)
            }
            .frame(maxWidth: .infinity)
            .disabled(language.isEmpty)

            HStack {
                Button(String(localized: "device_preferred_language_clear_button")) {
                    clearPreferredLanguage()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
                .disabled(!hasPreferredLanguage)

                Button(String(localized: "device_preferred_language_sample_button")) {
                    updatePreferredLanguage("pt-PT")
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
            }
        } header: {
            Text(String(localized: "device_preferred_language_header"))
        }
    }
}

internal struct PreferredLanguageSection_Previews: PreviewProvider {
    internal static var previews: some View {
        @State var language = ""
        List {
            PreferredLanguageSection(
                hasPreferredLanguage: false,
                updatePreferredLanguage: { _ in },
                clearPreferredLanguage: {}
            )
        }
    }
}
