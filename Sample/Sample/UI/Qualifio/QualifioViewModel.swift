//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import OSLog
import QualifioKit

@MainActor
internal class QualifioViewModel: ObservableObject {
    internal static let sampleCampaign = "sdk-xmas"

    @Published internal var campaign = QualifioViewModel.sampleCampaign
    @Published internal private(set) var launchState: LaunchState = .idle
    @Published internal var inlineCampaignInput = QualifioViewModel.sampleCampaign
    @Published internal private(set) var inlineCampaign = QualifioViewModel.sampleCampaign
    @Published internal var isInlineCampaignVisible = true

    internal func launchCampaign() {
        let campaign = resolvedCampaign(campaign)
        launchState = .loading

        Task {
            do {
                try await Qualifio.shared.launchCampaign(campaign)

                Logger.main.info("Qualifio campaign launched")
                launchState = .idle
            } catch {
                Logger.main.error("Failed to launch the Qualifio campaign: \(error)")
                launchState = .failure(error: error)
            }
        }
    }

    internal func loadInlineCampaign() {
        inlineCampaign = resolvedCampaign(inlineCampaignInput)
    }

    private func resolvedCampaign(_ text: String) -> String {
        let campaign = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return campaign.isEmpty ? Self.sampleCampaign : campaign
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
