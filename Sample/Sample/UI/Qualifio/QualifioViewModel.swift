//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import OSLog
import QualifioKit

@MainActor
internal class QualifioViewModel: ObservableObject {
    @Published internal var campaign = ""
    @Published internal private(set) var launchState: LaunchState = .idle
    @Published internal private(set) var inlineCampaign = Qualifio.DEFAULT_CAMPAIGN
    @Published internal var isInlineCampaignVisible = true

    internal let inlineCampaigns = [Qualifio.DEFAULT_CAMPAIGN, "sdk-xmas"]

    internal func launchCampaign() {
        let campaign = campaign.trimmingCharacters(in: .whitespacesAndNewlines)
        launchState = .loading

        Task {
            do {
                if campaign.isEmpty {
                    try await Qualifio.shared.launchCampaign()
                } else {
                    try await Qualifio.shared.launchCampaign(campaign)
                }

                Logger.main.info("Qualifio campaign launched")
                launchState = .idle
            } catch {
                Logger.main.error("Failed to launch the Qualifio campaign: \(error)")
                launchState = .failure(error: error)
            }
        }
    }

    internal func loadInlineCampaign(_ campaign: String) {
        inlineCampaign = campaign
    }

    internal enum LaunchState {
        case idle
        case loading
        case failure(error: Error)

        internal var isLoading: Bool {
            if case .loading = self {
                return true
            }

            return false
        }
    }
}
