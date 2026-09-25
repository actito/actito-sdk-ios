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
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            Button {
                updatePreferredLanguage(language)
                language = ""
            } label: {
                Text(String(localized: "device_preferred_language_button"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(language.isEmpty)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            HStack {
                Button {
                    clearPreferredLanguage()
                } label: {
                    Text(String(localized: "device_preferred_language_clear_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasPreferredLanguage)

                Button {
                    updatePreferredLanguage("pt-PT")
                } label: {
                    Text(String(localized: "device_preferred_language_sample_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))

        } header: {
            Text(String(localized: "device_preferred_language_header"))
        }
        .listRowSeparator(.hidden)
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
