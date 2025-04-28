//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Actito {
    public func device() -> ActitoDeviceModule {
        ActitoDeviceModuleImpl.instance
    }

    public func events() -> ActitoEventsModule {
        ActitoEventsModuleImpl.instance
    }
}

extension Actito {
    internal func deviceImplementation() -> ActitoDeviceModuleImpl {
        ActitoDeviceModuleImpl.instance
    }

    internal func eventsImplementation() -> ActitoEventsModuleImpl {
        ActitoEventsModuleImpl.instance
    }

    internal func session() -> ActitoSessionModuleImpl {
        ActitoSessionModuleImpl.instance
    }

    internal func crashReporter() -> ActitoCrashReporterModuleImpl {
        ActitoCrashReporterModuleImpl.instance
    }
}
