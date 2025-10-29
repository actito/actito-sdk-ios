//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

public final class ActitoLocalizable {
    public static func string(resource: StringResource) -> String {
        string(resource: resource.rawValue, fallback: "")
    }

    public static func string(resource: String, fallback: String) -> String {
        let bundle = Bundle(for: Self.self) // The bundle for the framework.
        let actitoStr = NSLocalizedString(resource, tableName: nil, bundle: bundle, value: fallback, comment: "")

        return NSLocalizedString(resource, tableName: nil, bundle: Bundle.main, value: actitoStr, comment: "")
    }

    public static func image(resource: ImageResource) -> UIImage? {
        if let overwrittenImage = UIImage(named: resource.rawValue, in: Bundle.main, compatibleWith: nil) {
            return overwrittenImage
        }

        let bundle = Bundle(for: Self.self) // The bundle for the framework.
        return UIImage(named: resource.rawValue, in: bundle, compatibleWith: nil)
    }

    public enum StringResource: String {
        case okButton = "actito_ok_button"
        case cancelButton = "actito_cancel_button"
        case closeButton = "actito_close_button"
        case sendButton = "actito_send_button"
        case actionsButton = "actito_actions_button"

        case pushDefaultCategory = "actito_push_default_category"

        case actionsInputPlaceholder = "actito_actions_input_placeholder"
        case actionsShareImageTextPlaceholder = "notification_actions_share_image_text_placeholder"

        case rateAlertYesButton = "actito_rate_alert_yes_button"
        case rateAlertNoButton = "actito_rate_alert_no_button"

        case mapUnknownTitleMarker = "actito_map_unknown_title_marker"

        case actionMailSubject = "actito_action_mail_subject"
        case actionMailBody = "actito_action_mail_body"
    }

    public enum ImageResource: String {
        case actions = "actito_actions"
        case mapMarker = "actito_map_marker"
        case mapMarkerUserLocation = "actito_map_marker_user_location"
        case close = "actito_close"
        case closeCircle = "actito_close_circle"
        case send = "actito_send"
    }
}
