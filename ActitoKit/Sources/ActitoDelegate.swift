//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

@MainActor
public protocol ActitoDelegate: AnyObject {
    /// Called when the Actito SDK is launched and fully ready.
    ///
    /// This method is triggered when the SDK has completed initialization and the ``ActitoApplication`` instance is available.
    /// Implement to perform actions when the SDK is ready.
    ///
    /// - Parameters:
    ///   - actito: The Actito object instance.
    ///   - application: The ``ActitoApplication`` containing the application's metadata.
    func actito(_ actito: Actito, onReady application: ActitoApplication)

    /// Called when the Actito SDK has been unlaunched.
    ///
    /// This method is triggered when the SDK has been shut down, indicating that it is no longer active.
    /// Implement this method to perform cleanup or update the app state based on the SDK's unlaunching.
    ///
    /// - Parameters:
    ///   - actito: The Actito object instance.
    func actitoDidUnlaunch(_ actito: Actito)

    /// Called when the device has been successfully registered with the Actito platform.
    ///
    /// This method is triggered after the device is initially created, which
    /// happens the first time `launch()` is called.
    /// Once created, the method will not trigger again unless the device is
    /// deleted by calling `unlaunch()` and created again on a new `launch()`.
    /// Implement this method to perform additional actions, such as updating user data or updating device attributes.
    /// 
    /// - Parameters:
    ///   - actito: The Actito object instance.
    ///   - device: The registered ``ActitoDevice`` instance representing the device's registration details.
    func actito(_ actito: Actito, didRegisterDevice device: ActitoDevice)
}

extension ActitoDelegate {
    public func actito(_: Actito, didRegisterDevice _: ActitoDevice) {}

    public func actitoDidUnlaunch(_: Actito) {}
}
