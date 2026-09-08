//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct DeviceView: View {
    @StateObject private var viewModel = DeviceViewModel()
    @State private var presentedAlert: PresentedAlert?

    internal var body: some View {
        List {
            CurrentDeviceSection(
                device: viewModel.currentDevice,
                language: viewModel.preferredLanguage
            )

            DoNotDisturbSection(
                hasDndEnabled: $viewModel.hasDndEnabled,
                startTime: $viewModel.startTime,
                endTime: $viewModel.endTime,
                updateDndStatus: { enabled in viewModel.updateDndStatus(enabled: enabled) },
                updateDndTime: { viewModel.updateDndTime() }
            )

            UserDataSection(
                userData: viewModel.userData,
                updateUserData: { data in viewModel.updateUserData(data) },
            )

            RegisterUserSection(
                isDeviceRegistered: viewModel.isDeviceRegistered,
                registerUser: { id, name in
                    viewModel.registerUser(userId: id, userName: name)
                },
                registerAnonymousUser: { viewModel.registerAnonymousUser() }
            )

            PreferredLanguageSection(
                hasPreferredLanguage: viewModel.hasPreferredLanguage,
                updatePreferredLanguage: {language in
                    viewModel.updatePreferredLanguage(preferredLanguage: language)
                },
                clearPreferredLanguage: { viewModel.clearPreferredLanguage() }
            )
        }
        .navigationTitle(String(localized: "device_title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $presentedAlert, content: createPresentedAlert)
        .onChange(of: viewModel.userMessages) { userMessages in
            if presentedAlert != nil { return }

            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .updateDoNotDisturbSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .updateDoNotDisturbFailure:
                presentedAlert = PresentedAlert(variant: .updateDoNotDisturbFailure, userMessageId: userMessage.uniqueId)

            case .clearDoNotDisturbSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clearDoNotDisturbFailure:
                presentedAlert = PresentedAlert(variant: .clearDoNotDisturbFailure, userMessageId: userMessage.uniqueId)

            case .updateUserDataSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .updateUserDataFailure:
                presentedAlert = PresentedAlert(variant: .updateUserDataFailure, userMessageId: userMessage.uniqueId)

            case .registerDeviceSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .registerDeviceFailure:
                presentedAlert = PresentedAlert(variant: .registerDeviceFailure, userMessageId: userMessage.uniqueId)

            case .registerAnonymousSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .registerAnonymousFailure:
                presentedAlert = PresentedAlert(variant: .registerAnonymousFailure, userMessageId: userMessage.uniqueId)

            case .updatePreferredLanguageSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .updatePreferredLanguageFailure:
                presentedAlert = PresentedAlert(variant: .updatePreferredLanguageFailure, userMessageId: userMessage.uniqueId)

            case .clearPreferredLanguageSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clearPreferredLanguageFailure:
                presentedAlert = PresentedAlert(variant: .clearPreferredLanguageFailure, userMessageId: userMessage.uniqueId)

            }
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .updateDoNotDisturbFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_update_dnd")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .clearDoNotDisturbFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_clear_dnd")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .updateUserDataFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_update_user_data")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .registerDeviceFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_register_device")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .registerAnonymousFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_register_anonymous_device")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .updatePreferredLanguageFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_update_preferred_language")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .clearPreferredLanguageFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_device_clear_preferred_language")),
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
            case updateDoNotDisturbFailure
            case clearDoNotDisturbFailure
            case updateUserDataFailure
            case registerDeviceFailure
            case registerAnonymousFailure
            case updatePreferredLanguageFailure
            case clearPreferredLanguageFailure
        }
    }
}

internal struct DeviceView_Previews: PreviewProvider {
    internal static var previews: some View {
        DeviceView()
    }
}
