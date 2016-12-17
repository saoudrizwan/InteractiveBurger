//
//  AppDelegate.swift
//  InteractiveBurger
//
//  Created by Saoud Rizwan on 12/16/16.
//  Copyright © 2016 Saoud Rizwan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // set the rootViewController to the first UIViewController of the stack, an instance of ViewController class
        window?.rootViewController = ViewController()
        
        return true
    }
    
    
}

