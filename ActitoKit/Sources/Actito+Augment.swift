//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Actito {
    public func device() -> ActitoDeviceComponent {
        ActitoDeviceComponent.shared
    }

    public func events() -> ActitoEventsComponent {
        ActitoEventsComponentImpl.instance
    }
}

extension Actito {
    internal func eventsImplementation() -> ActitoEventsComponentImpl {
        ActitoEventsComponentImpl.instance
    }

    internal func session() -> ActitoSessionComponent {
        ActitoSessionComponent.instance
    }

    internal func crashReporter() -> ActitoCrashReporterComponent {
        ActitoCrashReporterComponent.instance
    }
}
