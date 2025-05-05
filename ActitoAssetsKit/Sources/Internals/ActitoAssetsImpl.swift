//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

internal class ActitoAssetsImpl: NSObject, ActitoModule, ActitoAssets {
    // MARK: - Actito Module
    
    internal static let instance = ActitoAssetsImpl()
    
    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false
    }
    
    // MARK: - Actito Assets
    
    public func fetch(group: String, _ completion: @escaping ActitoCallback<[ActitoAsset]>) {
        Task {
            do {
                let result = try await fetch(group: group)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func fetch(group: String) async throws -> [ActitoAsset] {
        try checkPrerequisites()
        
        guard let urlEncodedGroup = group.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw ActitoError.invalidArgument(message: "Invalid group value.")
        }
        
        let response = try await ActitoRequest.Builder()
            .get("/asset/forgroup/\(urlEncodedGroup)")
            .query(name: "deviceID", value: Actito.shared.device().currentDevice?.id)
            .query(name: "userID", value: Actito.shared.device().currentDevice?.userId)
            .responseDecodable(ActitoInternals.PushAPI.Responses.Assets.self)
        
        let assets = response.assets.map { $0.toModel() }
        
        return assets
    }
    
    // MARK: - Internal API
    
    private func checkPrerequisites() throws {
        if !Actito.shared.isReady {
            logger.warning("Actito is not ready yet.")
            throw ActitoError.notReady
        }
        
        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            throw ActitoError.applicationUnavailable
        }
        
        if application.services[ActitoApplication.ServiceKey.storage.rawValue] != true {
            logger.warning("Actito storage functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.storage.rawValue)
        }
    }
}
