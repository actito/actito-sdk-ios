//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct NotificationsSection: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var presentedAlert: PresentedAlert?

    internal var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasNotificationsAndPermission) {
                Label {
                    Text(String(localized: "home_notifications"))
                } icon: {
                    ListIconView(
                        icon: "bell.badge.fill",
                        foregroundColor: .white,
                        backgroundColor: .green
                    )
                }
            }
            .onChange(of: viewModel.hasNotificationsAndPermission) { enabled in
                viewModel.updateNotificationsStatus(enabled: enabled)
            }

            HStack {
                Text(String(localized: "home_notifications_permission"))

                Spacer()

                Text(String(viewModel.notificationsPermission?.localized ?? ""))
            }

            HStack {
                Text(String(localized: "home_notifications_allowed_ui"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.allowedUi))
            }

            HStack {
                Text(String(localized: "home_notifications_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.hasNotificationsEnabled))
            }

            HStack {
                Text(String(localized: "home_notifications_subscription_token"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text((viewModel.subscription?.token).map { "...\($0.suffix(16))" } ?? "")
            }

            NavigationLink {
                InboxView()
            } label: {
                HStack {
                    Label {
                        Text(String(localized: "home_notifications_inbox"))
                    } icon: {
                        ListIconView(
                            icon: "tray.and.arrow.down.fill",
                            foregroundColor: .white,
                            backgroundColor: Color(.systemTeal)
                        )
                    }

                    Spacer()

                    if viewModel.badge > 0 {
                        BadgeView(badge: viewModel.badge)
                    }
                }
            }

            if #available(iOS 16.1, *), LiveActivitiesController.shared.hasLiveActivityCapabilities {
                NavigationLink {
                    LiveActivityView()
                } label: {
                    Label {
                        Text(String(localized: "home_notifications_live_activity"))
                    } icon: {
                        ListIconView(
                            icon: "bolt.fill",
                            foregroundColor: .white,
                            backgroundColor: .blue
                        )
                    }
                }
            }
        } header: {
            Text(String(localized: "home_notifications_header"))
        }
        .alert(item: $presentedAlert, content: createPresentedAlert)
        .onChange(of: viewModel.userMessages) { userMessages in
            if presentedAlert != nil { return }

            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .requestNotificationsPermissionSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .requestNotificationsPermissionFailure:
                presentedAlert = PresentedAlert(variant: .requestNotificationsPermissionFailure, userMessageId: userMessage.uniqueId)

            case .enableRemoteNotificationsSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .enableRemoteNotificationsFailure:
                presentedAlert = PresentedAlert(variant: .enableRemoteNotificationsFailure, userMessageId: userMessage.uniqueId)
            }
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .requestNotificationsPermissionFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_notifications_permission")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .enableRemoteNotificationsFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_notifications_enable")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )
        }
    }

    private struct PresentedAlert: Identifiable {
        let id = UUID().uuidString
        let variant: Variant
        let userMessageId: String

        enum Variant {
            case requestNotificationsPermissionFailure
            case enableRemoteNotificationsFailure
        }
    }
}

internal struct NotificationsSection_Previews: PreviewProvider {
    internal static var previews: some View {
        @State var hasNotificationsAndPermission = false
        List {
            NotificationsSection()
        }
    }
}
