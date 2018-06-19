//
//  LaunchController.swift
//  PopulationQuery
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

import Foundation
import Bugsnag

/// Class than handles launch control from applicationDidFinishLaunching
struct LaunchController {
    
    /**
     Begins analytics services
     - Returns: void
     */
    static func beginAnalytics() {
        let applicationKeys = PopulationQueryKeys()
        Bugsnag.start(withApiKey: applicationKeys.bugsnagAPIKey)
    }
}
