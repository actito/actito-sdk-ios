//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoScannablesKit
import OSLog
import SwiftUI

internal struct ScannablesView: View {
    internal var body: some View {
        List {
            Section {
                VStack {
                    Button(String(localized: "scannables_nfc")) {
                        Logger.main.info("NFC scan clicked")
                        Actito.shared.scannables().startNfcScannableSession()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(!Actito.shared.scannables().canStartNfcScannableSession)

                    Divider()

                    Button(String(localized: "scannables_qr_code")) {
                        Logger.main.info("QR Code scan clicked")
                        guard let rootViewController = UIApplication.shared.rootViewController else {
                            return
                        }

                        Actito.shared.scannables().startQrCodeScannableSession(controller: rootViewController, modal: true)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            } header: {
                Text(String(localized: "scannables_scannable_session"))
            }
        }
        .navigationTitle(String(localized: "scannables_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct ScannablesView_Previews: PreviewProvider {
    internal static var previews: some View {
        ScannablesView()
    }
}
