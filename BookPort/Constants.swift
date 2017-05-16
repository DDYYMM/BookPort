//
//  Constants.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/17/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit

class Constants: NSObject {
    // send bird
    //static let sendBirdAppId = "1754D364-8F39-4A56-9BB4-56C864B30871"
    //static let sendBirdApiToken = "cf5e77a80465353ccaac33a7c520fa51fa753a46"
    static let sendBirdAppId = "ACFAC6CF-5BC1-477F-A4DB-E092ACC7EF8F"
    static let sendBirdApiToken = "b76040a97611e1897a8b0dfa5e65ae224e6d4533"

    // keys for user defaults
    static let userIdKey = "userID"
    static let lonKey = "lon"
    static let latKey = "lat"
    static let nameKey = "name"
    static let profileUrlKey = "profileUrl"
    static let emailKey = "email"

    // tab view indices 
    static let profileTabIndex = 1
    static let chatTabIndex = 2
    static let homeTabIndex = 0
    
    static func navigationBarTitleColor() -> UIColor {
        return UIColor(red: 128.0/255.0, green: 90.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    static func navigationBarTitleFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 16.0)!
    }
    
    static func textFieldLineColorNormal() -> UIColor {
        return UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1)
    }
    
    static func textFieldLineColorSelected() -> UIColor {
        return UIColor(red: 140.0/255.0, green: 109.0/255.0, blue: 238.0/255.0, alpha: 1)
    }
    
    static func nicknameFontInMessage() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 12.0)!
    }
    
    static func nicknameColorInMessageNo0() -> UIColor {
        return UIColor(red: 45.0/255.0, green: 27.0/255.0, blue: 225.0/255.0, alpha: 1)
    }
    
    static func nicknameColorInMessageNo1() -> UIColor {
        return UIColor(red: 53.0/255.0, green: 163.0/255.0, blue: 251.0/255.0, alpha: 1)
    }
    
    static func nicknameColorInMessageNo2() -> UIColor {
        return UIColor(red: 128.0/255.0, green: 90.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    static func nicknameColorInMessageNo3() -> UIColor {
        return UIColor(red: 207.0/255.0, green: 72.0/255.0, blue: 251.0/255.0, alpha: 1)
    }
    
    static func nicknameColorInMessageNo4() -> UIColor {
        return UIColor(red: 226.0/255.0, green: 27.0/255.0, blue: 225.0/255.0, alpha: 1)
    }
    
    static func messageDateFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 10.0)!
    }
    
    static func messageDateColor() -> UIColor {
        return UIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1)
    }
    
    static func incomingFileImagePlaceholderColor() -> UIColor {
        return UIColor(red: 238.0/255.0, green: 241.0/255.0, blue: 246.0/255.0, alpha: 1)
    }
    
    static func messageFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 16.0)!
    }
    
    static func outgoingFileImagePlaceholderColor() -> UIColor {
        return UIColor(red: 128.0/255.0, green: 90.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    static func openChannelLineColorNo0() -> UIColor {
        return UIColor(red: 45.0/255.0, green: 227.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    static func openChannelLineColorNo1() -> UIColor {
        return UIColor(red: 53.0/255.0, green: 163.0/255.0, blue: 251.0/255.0, alpha: 1)
    }
    
    static func openChannelLineColorNo2() -> UIColor {
        return UIColor(red: 128.0/255.0, green: 90.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    static func openChannelLineColorNo3() -> UIColor {
        return UIColor(red: 207.0/255.0, green: 72.0/255.0, blue: 251.0/255.0, alpha: 1)
    }
    
    static func openChannelLineColorNo4() -> UIColor {
        return UIColor(red: 226.0/255.0, green: 72.0/255.0, blue: 195.0/255.0, alpha: 1)
    }
    
    static func leaveButtonColor() -> UIColor {
        return UIColor.red
    }
    
    static func hideButtonColor() -> UIColor {
        return UIColor(red: 116.0/255.0, green: 127.0/255.0, blue: 145.0/255.0, alpha: 1)
    }
    
    static func leaveButtonFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 18.0)!
    }
    
    static func hideButtonFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 18.0)!
    }
    
    static func distinctButtonSelected() -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: 18.0)!
    }
    
    static func distinctButtonNormal() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 18.0)!
    }
    
    static func navigationBarButtonItemFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 16.0)!
    }
    
    static func memberOnlineTextColor() -> UIColor {
        return UIColor(red: 41.0/255.0, green: 197.0/255.0, blue: 25.0/255.0, alpha: 1)
    }
    
    static func memberOfflineDateTextColor() -> UIColor {
        return UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 142.0/255.0, alpha: 1)
    }
    
    static func connectButtonColor() -> UIColor {
        return UIColor(red: 123.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1)
    }
}
