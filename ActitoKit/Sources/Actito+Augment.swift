//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Actito {
    internal func eventsImplementation() -> ActitoEventsComponent {
        ActitoEventsComponent.instance
    }

    internal func session() -> ActitoSessionComponent {
        ActitoSessionComponent.instance
    }

    internal func crashReporter() -> ActitoCrashReporterComponent {
        ActitoCrashReporterComponent.instance
    }
}
