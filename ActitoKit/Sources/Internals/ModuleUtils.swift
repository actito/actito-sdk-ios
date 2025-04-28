//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

public enum ModuleUtils {
    public static func getEnabledPeerModules() -> [String] {
        ActitoInternals.Module.allCases
            .filter { $0.isPeer && $0.isAvailable }
            .map { "\($0)" }
    }
}
