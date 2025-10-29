//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Actito {
    public func device() -> ActitoDeviceModule {
        ActitoDeviceModule.shared
    }

    public func events() -> ActitoEventsModule {
        ActitoEventsModuleImpl.instance
    }
}

extension Actito {
    internal func eventsImplementation() -> ActitoEventsModuleImpl {
        ActitoEventsModuleImpl.instance
    }

    internal func session() -> ActitoSessionModule {
        ActitoSessionModule.instance
    }

    internal func crashReporter() -> ActitoCrashReporterModule {
        ActitoCrashReporterModule.instance
    }
}
