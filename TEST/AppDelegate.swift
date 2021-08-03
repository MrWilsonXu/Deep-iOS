//
//  AppDelegate.swift
//  TEST
//
//  Created by Wilson on 2020/3/16.
//  Copyright © 2020 Wilson. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "ViewController")
        self.window?.rootViewController = UINavigationController(rootViewController: vc)
        print(NSHomeDirectory())
        return true
    }
}

