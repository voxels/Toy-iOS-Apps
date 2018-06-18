//
//  Font.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

// MARK: - App Defaults

/// Default view font sizes
enum FontSize : CGFloat {
    case highlighted =  30.0
    case title =        22.0
    case button =       14.0
    case tagline =      12.0
}

/// Lato font family cases
enum LatoFamilyNames {
    case regular
    case italic
    case black
    case blackItalic
    case bold
    case boldItalic
    case light
    case lightItalic
    case hairline
    case hairlineItalic
    
    func name()->String{
        switch self
        {
        case .regular:
            return "Lato"
        case .italic:
            return "Lato-Italic"
        case .black:
            return "Lato-Black"
        case .blackItalic:
            return "Lato-BlackItalic"
        case .bold:
            return "Lato-Bold"
        case .boldItalic:
            return "Lato-BoldItalic"
        case .light:
            return "Lato-Light"
        case .lightItalic:
            return "Lato-LightItalic"
        case .hairline:
            return "Lato-Hairline"
        case .hairlineItalic:
            return "Lato-HairlineItalic"
        }
    }
}

// MARK: - Convenience methods
extension UIFont {
    
    /**
     Returns the default highlighted font face
     - Returns: A UIFont for highlighted text
     */
    static func appFontHighlighted()->UIFont
    {
        return UIFont.systemFont(ofSize: FontSize.highlighted.rawValue)
    }

    /**
     Returns the default navigation font face
     - Returns: A UIFont for navigation text
     */
    static func appFontNavigation()->UIFont {
        return UIFont.systemFont(ofSize: FontSize.title.rawValue)
    }
    
    /**
     Returns the default title font face
     - Returns: A UIFont for title text
     */
    static func appFontTitle()->UIFont {
        if let font = UIFont(name: LatoFamilyNames.bold.name(), size: FontSize.title.rawValue)
        {
            return font
        }
        
        return UIFont.systemFont(ofSize: FontSize.title.rawValue)
    }
    
    /**
     Returns the default button font face
     - Returns: A UIFont for button text
     */

    static func appFontButton()->UIFont {
        if let font = UIFont(name: LatoFamilyNames.bold.name(), size: FontSize.button.rawValue)
        {
            return font
        }
        
        return UIFont.systemFont(ofSize: FontSize.button.rawValue)
    }
    
    /**
     Returns the default tagline font face
     - Returns: A UIFont for tagline text
     */

    static func appFontTagline()->UIFont {        
        return UIFont.italicSystemFont(ofSize: FontSize.tagline.rawValue)
    }
    
    /**
     Returns the default font face
     - Returns: A UIFont for text
     */
    static func appFontSized(size:CGFloat)->UIFont
    {
        return UIFont.systemFont(ofSize:size)
    }
}

// MARK: - Font families

extension UIFont {
    /**
     Prints the installed font family names to the console
     */
    static func displayFontNames()
    {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
}
