//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

public protocol ActitoScannablesDelegate: AnyObject {
    /// Called when an error occurs during a scannable session.
    ///
    /// - Parameters:
    ///   - actitoScannables: The ActitoScannables object instance.
    ///   - error: The ``Error`` that invalidated the scannable session.
    func actito(_ actitoScannables: ActitoScannables, didInvalidateScannerSession error: Error)

    /// Called when a scannable item is detected during a scannable session.
    ///
    /// - Parameters:
    ///   - actitoScannables: The ActitoScannablesobject instance.
    ///   - scannable: The detected ``ActitoScannable`` object.
    func actito(_ actitoScannables: ActitoScannables, didDetectScannable scannable: ActitoScannable)
}

extension ActitoScannablesDelegate {
    public func actito(_: ActitoScannables, didInvalidateScannerSession _: Error) {}

    public func actito(_: ActitoScannables, didDetectScannable _: ActitoScannable) {}
}
