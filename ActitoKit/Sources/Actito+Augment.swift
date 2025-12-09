//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

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
