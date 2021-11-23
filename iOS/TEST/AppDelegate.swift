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
        requestBaidu()
        print("------------默认urlCache大小---------");
        printCacheSize()
        initNSUrlCache()
        print("------------设置的urlCache大小---------");
        printCacheSize()
        return true
    }
    
    func initNSUrlCache() {
        _ = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil);
    }
    
    func printCacheSize() {
        print(URLCache.shared.diskCapacity)
        print(URLCache.shared.memoryCapacity)
    }
    
    func requestBaidu() {
        let url = URL(string: "https://www.baidu.com")!
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60);
        let session = URLSession.shared
        let task = session .dataTask(with: request)
        task.resume()
    }
}

