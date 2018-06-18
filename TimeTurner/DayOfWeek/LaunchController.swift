//
//  LaunchController.swift
//  TimeTurner
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class LaunchController {
    
    /// Default navigation item attributes
    let navItemAttributes = [NSAttributedStringKey.font : UIFont.appFontNavigation(), NSAttributedStringKey.foregroundColor : UIColor.appGreenColor()]

    /// Default parent view controller, set as the root view controller for the root navigation controller
    let parentViewController = ParentViewController(nibName: nil, bundle: nil)
}

extension LaunchController {
    
    /**
     Starts analytic services
     - Returns: void
     */
    func beginAnalytics() {
        #if DEBUG
            Fabric.sharedSDK().debug = true
        #endif
        
        Fabric.with([Crashlytics.self])
    }
    
    /**
     Creates a navigation controller with a configured root parent view controller
     - parameter parentViewController: Parent View Controller set to the root
     - parameter itemAttributes: Navigation bar appearance attributes
     - parameter tintColor: Navigation bar tint color
     - Returns: UINavigationController
     */
    func navigationController(with parentViewController:ParentViewController, itemAttributes:[NSAttributedStringKey : Any]?, tintColor:UIColor)->UINavigationController {
        let navigationController = UINavigationController(rootViewController: parentViewController)
        configure(navigationController: navigationController, itemAttributes:itemAttributes, tintColor: tintColor)
        return navigationController
    }
}

extension LaunchController {
    /**
     Configures a navigation controller to hide the navigation bar and use the item attributes
     - parameter navigationController: Navigation controller used for configuration
     - parameter itemAttributes: Navigation bar appearance attributes
     - parameter tintColor: Navigation bar tint color
     - Returns: void
     */
    func configure(navigationController:UINavigationController, itemAttributes:[NSAttributedStringKey : Any]?, tintColor:UIColor)
    {
        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.titleTextAttributes = itemAttributes
        UINavigationBar.appearance().tintColor = UIColor.appMagentaColor()
    }    
}
