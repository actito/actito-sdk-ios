//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    internal var body: some View {
        List {
            Section {
                TextField(String(localized: "events_event_name"), text: $viewModel.eventName)
                    .disabled(viewModel.viewState.isLoading)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(uiColor: .separator))
                    )

                if !viewModel.viewState.isLoading {
                    ForEach($viewModel.eventFields) { $field in
                        EventFieldView(field: $field)
                    }
                }

                Button {
                    viewModel.registerEvent()
                } label: {
                    Text(String(localized: "events_register_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isRegisterEventAllowed)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
            } header: {
                HStack {
                    Text(String(localized: "events_header"))
                }
            }
            .listRowSeparator(.hidden)

            ZStack {
                switch viewModel.viewState {
                case .idle:
                    EmptyView()

                case .loading:
                    ProgressView()

                case .success:
                    Label {
                        Text(String(localized: "event_registered"))
                    } icon: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }

                case .failure:
                    Label {
                        Text(String(localized: "error_message_events_register"))
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(String(localized: "events_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(String(localized: "events_add_field")) {
                    viewModel.addEventField()
                }
            }
        }
    }
}

private struct EventFieldView: View {
    @Binding var field: EventField

    var body: some View {
        HStack {
            TextField(String(localized: "events_key"), text: $field.key)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            TextField(String(localized: "events_value"), text: $field.value)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )
        }
    }
}

internal struct EventsView_Previews: PreviewProvider {
    internal static var previews: some View {
        EventsView()
    }
}
