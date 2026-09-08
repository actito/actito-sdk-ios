//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct ActionCategoriesSection: View {
    internal let actionCategories = Actito.shared.application?.actionCategories

    internal var body: some View {
        Section {
            if let actionCategories {
                ForEach(actionCategories, id: \.name) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: "application_action_categories_type"))
                            Spacer()
                            Text(String(describing: category.type))
                        }
                        HStack {
                            Text(String(localized: "application_action_categories_name"))
                            Spacer()
                            Text(String(describing: category.name))
                        }
                        HStack {
                            Text(String(localized: "application_action_categories_description"))
                            Spacer()
                            Text(category.description ?? "nil")
                        }

                        if !category.actions.isEmpty {
                            Text(String(localized: "application_action_categories_actions"))

                            ForEach(category.actions, id: \.label) { action in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(String(localized: "application_action_categories_action_type"))
                                        Spacer()
                                        Text(String(describing: action.type))
                                    }

                                    HStack {
                                        Text(String(localized: "application_action_categories_action_label"))
                                        Spacer()
                                        Text(String(describing: action.label))
                                    }

                                    HStack {
                                        Text(String(localized: "application_action_categories_action_target"))
                                        Spacer()
                                        Text(String(describing: action.target))
                                    }

                                    HStack {
                                        Text(String(localized: "application_action_categories_action_camera"))
                                        Spacer()
                                        Text(String(describing: action.camera))
                                    }

                                    HStack {
                                        Text(String(localized: "application_action_categories_action_keyboard"))
                                        Spacer()
                                        Text(String(describing: action.keyboard))
                                    }

                                    HStack {
                                        Text(String(localized: "application_action_categories_action_destructive"))
                                        Spacer()
                                        Text(String(describing: action.destructive))
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(String(localized: "application_action_categories_action_icon"))
                                        }

                                        HStack {
                                            Text(String(localized: "application_action_categories_action_icon_android"))
                                            Spacer()
                                            Text(action.icon?.android ?? "nil")
                                        }

                                        HStack {
                                            Text(String(localized: "application_action_categories_action_ios"))
                                            Spacer()
                                            Text(action.icon?.ios ?? "nil")
                                        }

                                        HStack {
                                            Text(String(localized: "application_action_categories_action_web"))
                                            Spacer()
                                            Text(action.icon?.web ?? "nil")
                                        }
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.leading, 8)
                            }
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text(String(localized: "application_action_categories_header"))

                ChipView(text: String(describing: actionCategories!.count))
            }
        }
    }
}

internal struct ActionCategoriesSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            ActionCategoriesSection()
        }
    }
}
