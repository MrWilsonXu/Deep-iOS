//
//  BViewController.swift
//  TEST
//
//  Created by Wilson on 2020/3/17.
//  Copyright © 2020 Wilson. All rights reserved.
//

import UIKit

class BViewController: UIViewController, NSMachPortDelegate {
    var dpLink: CADisplayLink!
    var lastTime: TimeInterval = 0
    var count: TimeInterval = 0
    var notiString: String = "**"
    var block: (() -> Void)?
    
    deinit {
        print("\(self) --> release")
    }
    
    override func viewDidLoad() {
        self.title = "BVC"
        dpLink = CADisplayLink(target: self, selector: #selector(showFps))
        dpLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        addNotifation()
    }
    
    func addNotifation() {
        weak var weakSelf = self
        let queue = OperationQueue()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CViewControllerPost"), object: nil, queue: queue) { (notifation) in
            weakSelf?.notiString = "receive new notification"
        }
    }
    
    @IBAction func click(_ sender: Any) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 2)
            let thread = Thread.current
            print(thread)
            print("1")
        }
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 2)
            let thread = Thread.current
            print(thread)
            print("2")
        }
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 2)
            let thread = Thread.current
            print(thread)
            print("3")
        }
        
        let vc = CViewController()
        show(vc, sender: nil)
    }
    
    @objc func showFps(dpLink: CADisplayLink) {
        if lastTime == 0 {
            lastTime = dpLink.timestamp
            return
        }
        count += 1
        print(count)
        
        let delta = dpLink.timestamp - lastTime;
        if delta < 1 {return}
        
        lastTime = dpLink.timestamp;
        let fps = count / delta;
        count = 0
        print(fps)
        
        self.dpLink.invalidate()
        self.dpLink = nil
    }
}
