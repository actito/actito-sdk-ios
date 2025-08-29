//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import PassKit
import UIKit

@MainActor
public final class ActitoLoyalty {
    public static let shared = ActitoLoyalty()

    // MARK: - Public API

    /// Presents a pass to the user in the given view controller.
    ///
    /// - Parameters:
    ///   - pass: The ``ActitoPass`` to be presented to the user.
    ///   - controller: The ``UIViewController`` in which to present the pass.
    @MainActor
    public func present(pass: ActitoPass, in controller: UIViewController) {
        guard let host = Actito.shared.servicesInfo?.hosts.restApi,
              let url = URL(string: "https://\(host)/pass/pkpass/\(pass.serial)")
        else {
            logger.warning("Unable to determine the PKPass URL.")
            return
        }

        Task {
            do {
                let pass = try await loadPassFromUrl(url)
                present(pass, in: controller)
            } catch {
                logger.error("Failed to create PKPass from URL.", error: error)
            }
        }
    }

    /// Fetches a pass by its serial number, with a callback.
    ///
    /// - Parameters:
    ///   - serial: The serial number of the pass to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    public func fetchPass(serial: String, _ completion: @escaping ActitoCallback<ActitoPass>) {
        Task {
            do {
                let result = try await fetchPass(serial: serial)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches a pass by its serial number.
    ///
    /// - Parameters:
    ///   - serial: The serial number of the pass to be fetched.
    ///
    /// - Returns: The fetched ``ActitoPass`` corresponding to the given serial number.
    public func fetchPass(serial: String) async throws -> ActitoPass {
        try checkPrerequisites()

        guard let urlEncodedSerial = serial.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw ActitoError.invalidArgument(message: "Invalid serial value.")
        }

        let response = try await ActitoRequest.Builder()
            .get("/pass/forserial/\(urlEncodedSerial)")
            .responseDecodable(ActitoInternals.PushAPI.Responses.Pass.self)

        return try await enhancePass(response.pass)
    }

    /// Fetches a pass by its barcode, with a callback.
    ///
    /// - Parameters:
    ///   - barcode: The barcode of the pass to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    public func fetchPass(barcode: String, _ completion: @escaping ActitoCallback<ActitoPass>) {
        Task {
            do {
                let result = try await fetchPass(barcode: barcode)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches a pass by its barcode.
    ///
    /// - Parameters:
    ///   - barcode: The barcode of the pass to be fetched.
    ///
    /// - Returns: The fetched ``ActitoPass`` corresponding to the given barcode.
    public func fetchPass(barcode: String) async throws -> ActitoPass {
        try checkPrerequisites()

        guard let urlEncodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw ActitoError.invalidArgument(message: "Invalid barcode value.")
        }

        let response = try await ActitoRequest.Builder()
            .get("/pass/forbarcode/\(urlEncodedBarcode)")
            .responseDecodable(ActitoInternals.PushAPI.Responses.Pass.self)

        return try await enhancePass(response.pass)
    }

    // MARK: - Actito Loyalty Integration

    @MainActor
    internal var canPresentPasses: Bool {
        PKPassLibrary.isPassLibraryAvailable() && PKAddPassesViewController.canAddPasses()
    }

    @MainActor
    internal func present(notification: ActitoNotification, in viewController: UIViewController) {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.PKPass" }),
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            logger.warning("Trying to present a notification that doesn't contain a pass.")
            return
        }

        Task {
            do {
                let pass = try await loadPassFromUrl(url)
                present(pass, in: viewController)
            } catch {
                logger.error("Failed to create PKPass from URL.", error: error)
            }
        }
    }

    // MARK: - Internal API

    private func checkPrerequisites() throws {
        if !Actito.shared.isReady {
            logger.warning("Actito is not ready yet.")
            throw ActitoError.notReady
        }

        if Actito.shared.device().currentDevice == nil {
            logger.warning("Actito device is not yet available.")
            throw ActitoError.deviceUnavailable
        }

        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            throw ActitoError.applicationUnavailable
        }

        guard application.services[ActitoApplication.ServiceKey.passbook.rawValue] == true else {
            logger.warning("Actito loyalty functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.passbook.rawValue)
        }
    }

    private func enhancePass(_ pass: ActitoInternals.PushAPI.Models.Pass) async throws -> ActitoPass {
        if pass.version == 1, let passbook = pass.passbook {
            let type = try await fetchPassType(passbook: passbook)

            return createPassModel(pass, passType: type)
        }

        return createPassModel(pass, passType: nil)
    }

    private func fetchPassType(passbook: String) async throws -> ActitoPass.PassType {
        let response = try await ActitoRequest.Builder()
            .get("/passbook/\(passbook)")
            .responseDecodable(ActitoInternals.PushAPI.Responses.FetchPassbookTemplate.self)

        return response.passbook.passStyle
    }

    private func createPassModel(_ pass: ActitoInternals.PushAPI.Models.Pass, passType: ActitoPass.PassType?) -> ActitoPass {
        ActitoPass(
            id: pass._id,
            type: passType,
            version: pass.version,
            passbook: pass.passbook,
            template: pass.template,
            serial: pass.serial,
            barcode: pass.barcode,
            redeem: pass.redeem,
            redeemHistory: pass.redeemHistory,
            limit: pass.limit,
            token: pass.token,
            data: pass.data?.value as? [String: Any] ?? [:],
            date: pass.date
        )
    }

    private func loadPassFromUrl(_ url: URL) async throws -> sending PKPass {
        let (data, response) = try await URLSession.shared.data(from: url)
        let validStatusCodes = 200 ... 299

        if let httpResponse = response as? HTTPURLResponse, !validStatusCodes.contains(httpResponse.statusCode) {
            throw ActitoNetworkError.validationError(response: httpResponse, data: data, validStatusCodes: validStatusCodes)
        }

        return try PKPass(data: data)
    }

    @MainActor
    private func present(_ pass: PKPass, in controller: UIViewController) {
        guard let passController = PKAddPassesViewController(pass: pass) else {
            logger.warning("Failed to create pass view controller.")
            return
        }

        if controller.presentedViewController != nil {
            controller.dismiss(animated: true) {
                controller.present(passController, animated: true)
            }
        } else {
            controller.present(passController, animated: true)
        }
    }
}
