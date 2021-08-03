//
//  ViewController.swift
//  TEST
//
//  Created by Wilson on 2020/3/16.
//  Copyright © 2020 Wilson. All rights reserved.
//

import UIKit

protocol pet {
    var name: String {get set}
}

struct MyDog: pet {
    var name: String
    mutating func change(name: String) {
        self.name = name
    }
}

struct Person {
    var name: String?
    var age: String?
}

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var ball: CustomerView!
    var arrA = [1,2,3]
    var arrB: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        ball = CustomerView(frame: CGRect(x: 0, y: 100, width: 50, height: 50))
        ball.backgroundColor = UIColor.red
        view.addSubview(ball)
        var p = Person()
        p.age = "wilson"
        
        DispatchQueue.global().async {
            Timer.scheduledTimer(withTimeInterval: 0.001, repeats: false) { (timer) in
                    for i in 1...100 {
                        let j = i + i*(i+1) / i*i*i
                        print(j)
                }
            }
            let runloop = RunLoop.current
            runloop.run()
        }
    }
    
    //测试swift中的值类型 copy-on-write
    func testValueType() {
        arrB = arrA as NSArray
        arrA.append(4)
        print(arrB!)
    }
    
    //swift科里化特性，体现了函数式变成特性
    func add(_ num: Int) -> (Int) -> Int {
        return { val in
            return num + val
        }
    }
    @IBAction func push(_ sender: Any) {
        let vc = DVC()
        show(vc, sender: nil)
    }
    
    @IBAction func click(_ sender: Any) {
        ball.backgroundColor = UIColor.black
        view.layoutIfNeeded()
        //OperationQueue 创建的自定义队列同时具有串行、并发功能
        let ope1 = BlockOperation {
            for _ in 0..<2 {
                //模拟耗时操作
                Thread.sleep(forTimeInterval: 2)
                print("1--->",Thread.current)
            }
        }
        let ope2 = BlockOperation {
            for _ in 0..<2 {
                //模拟耗时操作
                Thread.sleep(forTimeInterval: 2)
                print("2--->",Thread.current)
            }
        }
        let ope3 = BlockOperation {
            for _ in 0..<2 {
                //模拟耗时操作
                Thread.sleep(forTimeInterval: 2)
                print("3--->",Thread.current)
            }
        }
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 1
        //当设置maxConcurrentOperationCount=1时，变为串行队列
        queue.addOperation(ope1)
        queue.addOperation(ope2)
        queue.addOperation(ope3)
    }
    
    func testGCDQueue() {
        //主队列同步执行和Operation相互依赖都可以造成死锁
        /**
         DispatchQueue.main.sync {
            print("主队列同步，造成死锁")
         }
         */
        
        /**
        let op1 = BlockOperation()
        let op2 = BlockOperation()
        op1.addDependency(op2)
        op2.addDependency(op1)
        
        op1.addExecutionBlock {
            print("线程相互依赖1")
        }
        op2.addExecutionBlock {
            print("线程相互依赖2")
        }
        op1.start()
        op2.start()
        */
        
        let queue = DispatchQueue.init(label: "aaa")
        queue.sync {
            print("queue run in \(Thread.current)");
            print("10")
        }
        queue.sync {
            print("queue run in \(Thread.current)");
            print("11")
        }
        queue.sync {
            print("queue run in \(Thread.current)");
            print("12")
        }
        queue.sync {
            print("queue run in \(Thread.current)");
            print("13")
        }
        
        DispatchQueue.global().async {
            print("queue run in \(Thread.current)");
            print("1")
        }
        DispatchQueue.global().async {
            print("queue run in \(Thread.current)");
            print("2")
        }
        DispatchQueue.global().async {
            print("queue run in \(Thread.current)");
            print("3")
        }
    }
}

class CustomerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(catchNoti), name: NSNotification.Name(rawValue: "ball"), object: nil)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("触发了drawRect")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func removeNoti() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func catchNoti(noti: NSNotification) {
        if let name = noti.userInfo?["name"] {
            print("接收到通知：\(name)")
        }
        self.perform(#selector(delayPerform), with: nil, afterDelay: 1)
    }
    
    @objc func delayPerform() {
        print("子线程中，performSelector需要加入到runloop中才会执行")
    }
}

