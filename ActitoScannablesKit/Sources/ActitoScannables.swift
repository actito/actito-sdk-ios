//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import CoreNFC
import UIKit

@MainActor
public final class ActitoScannables: NSObject {
    public static let shared = ActitoScannables()

    // MARK: - Public API

    /// Specifies the delegate that handles scannables session events
    ///
    /// This property allows setting a delegate conforming to ``ActitoScannablesDelegate`` to respond to various scannables session events,
    /// such as such as when a scannable item is detected (either via NFC or QR code), or when an error occurs during the session.
    public weak var delegate: ActitoScannablesDelegate?

    /// Indicates whether an NFC scannable session can be started on the current device.
    ///
    /// Returns *true* if the device supports NFC scanning, otherwise *false*.
    public var canStartNfcScannableSession: Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    /// Starts a scannable session, automatically selecting the best scanning method available.
    ///
    /// If NFC is available, it starts an NFC-based scanning session. If NFC is not available, it defaults to starting
    /// a QR code scanning session.
    ///
    ///  - Parameters:
    ///    - controller: The ``UIViewController`` in which to start the scannable session.
    public func startScannableSession(controller: UIViewController) {
        if canStartNfcScannableSession {
            startNfcScannableSession()
        } else {
            startQrCodeScannableSession(controller: controller)
        }
    }

    /// Starts an NFC scannable session.
    ///
    /// Initiates an NFC-based scan, allowing the user to scan NFC tags. This will only function on devices that support NFC
    /// and have it enabled.
    public func startNfcScannableSession() {
        if canStartNfcScannableSession {
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.begin()
        } else {
            logger.warning("NFC scanning is not available. Please start a QR Code scannable session instead.")
        }
    }

    /// Starts a QR code scannable session.
    ///
    /// Initiates a QR code-based scan using the device camera, allowing the user to scan QR codes.
    ///
    /// - Parameters:
    ///   - controller: The ``UIViewController`` in which to start the scannable session.
    ///   - modal: A Boolean indicating whether the scanner should be presented modally (`true`) or embedded in the existing navigation flow (`false`).
    public func startQrCodeScannableSession(controller: UIViewController, modal: Bool = false) {
        let qrCodeScanner = ActitoQrCodeScannerViewController()
        qrCodeScanner.onQrCodeDetected = { qrCode in

            DispatchQueue.main.async {
                if let controller = controller as? UINavigationController, !modal {
                    controller.popViewController(animated: true)
                } else {
                    controller.dismiss(animated: true)
                }
            }

            self.handleScannableTag(qrCode)
        }

        if let controller = controller as? UINavigationController, !modal {
            controller.pushViewController(qrCodeScanner, animated: true)
        } else {
            if controller.presentedViewController != nil {
                controller.dismiss(animated: true) {
                    controller.present(qrCodeScanner, animated: true)
                }
            } else {
                controller.present(qrCodeScanner, animated: true)
            }
        }
    }

    /// Fetches a scannable item by its tag, with a callback.
    ///
    /// - Parameters:
    ///   - tag: The tag identifier for the scannable item to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    public func fetch(tag: String, _ completion: @escaping ActitoCallback<ActitoScannable>) {
        Task {
            do {
                let result = try await fetch(tag: tag)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches a scannable item by its tag.
    ///
    /// - Parameters:
    ///   - tag: The tag identifier for the scannable item to be fetched.
    ///
    /// - Returns: The ``ActitoScannable`` object corresponding to the provided tag.
    public func fetch(tag: String) async throws -> ActitoScannable {
        guard let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            throw ActitoError.invalidArgument(message: "Invalid tag value.")
        }

        let response = try await ActitoRequest.Builder()
            .get("/scannable/tag/\(encodedTag)")
            .query(name: "deviceID", value: Actito.shared.device().currentDevice?.id)
            .query(name: "userID", value: Actito.shared.device().currentDevice?.userId)
            .responseDecodable(ActitoInternals.PushAPI.Responses.Scannable.self)

        let scannable = response.scannable.toModel()
        return scannable
    }

    // MARK: - Private API

    private nonisolated func parseScannableTag(_ record: NFCNDEFPayload) -> String? {
        return record.wellKnownTypeURIPayload()?.absoluteString
    }

    private nonisolated func handleScannableTag(_ tag: String) {
        Task {
            do {
                let scannable = try await fetch(tag: tag)

                DispatchQueue.main.async {
                    self.delegate?.actito(self, didDetectScannable: scannable)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.actito(self, didInvalidateScannerSession: error)
                }
            }
        }
    }
}

extension ActitoScannables: NFCNDEFReaderSessionDelegate {
    public nonisolated func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        messages.forEach { message in
            message.records.forEach { record in
                if
                    record.typeNameFormat == .nfcWellKnown,
                    let type = String(data: record.type, encoding: .utf8),
                    type == "U", // only supports URL payloads
                    let tag = parseScannableTag(record)
                {
                    handleScannableTag(tag)
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.actito(self, didInvalidateScannerSession: ActitoScannablesError.unsupportedScannable)
                    }
                }
            }
        }
    }

    public nonisolated func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // When invalidateAfterFirstRead is YES, the reader session automatically terminates after the first NFC tag is successfully read.
        // In this scenario, the delegate receives the NFCReaderSessionInvalidationErrorFirstNDEFTagRead status.
        if let error = error as? NFCReaderError, error.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
            return
        }

        DispatchQueue.main.async {
            self.delegate?.actito(self, didInvalidateScannerSession: error)
        }
    }
}
