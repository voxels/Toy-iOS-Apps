//
//  Color.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

// MARK: - Convenience methods

extension UIColor {

    /**
     Returns the default magenta color
     - Returns: A magenta UIColor
     */
    static func appMagentaColor()->UIColor
    {
        return UIColor(red: 182.0/255.0, green: 0.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    }

    /**
     Returns the default lemon color
     - Returns: A lemon UIColor
     */
    static func appLemonColor()->UIColor
    {
        return UIColor(red: 245.0/255.0, green: 216.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    }
    
    /**
     Returns the default gold color
     - Returns: A gold UIColor
     */
    static func appGoldColor()->UIColor
    {
        return UIColor(red: 255.0/255.0, green: 158.0/255.0, blue: 22.0/255.0, alpha: 1.0)
    }
    
    /**
     Returns the default green color
     - Returns: A green UIColor
     */
    static func appGreenColor()->UIColor
    {
        return UIColor(red: 108.0/255.0, green: 192.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    }
    
    /**
     Returns the default neutral color
     - Returns: A neutral UIColor
     */
    static func appNeutralColor()->UIColor
    {
        return UIColor(red: 142.0/255.0, green: 130.0/255.0, blue: 121.0/255.0, alpha: 1.0)
    }
    
    /**
     Returns the default background top color
     - Returns: A background top UIColor
     */
    static func backgroundTopColor()->UIColor
    {
        return UIColor(red: 249.0/255.0, green: 218.0/255.0, blue: 223.0/255.0, alpha: 1.0)
    }    
}
