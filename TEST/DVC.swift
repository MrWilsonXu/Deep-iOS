//
//  DVC.swift
//  TEST
//
//  Created by Wilson on 2020/5/18.
//  Copyright © 2020 Wilson. All rights reserved.
//

import RxSwift
import RxCocoa

protocol Eatable {

}

/**
 现在的这个Eatable协议是可以被任意遵守的，如果我们有这么个需求，我们创建的协议只是被UIViewController遵守，那我们该怎么做呢？
 在 extension 后面加上约束关键字【where】并注明该协议只能被UIViewController这个类（包括子类）所遵守
 而且此时我们还可以拿到遵守该协议的控制器的view
 */
extension Eatable where Self: UIViewController {
    func eat() {
        view.backgroundColor = UIColor.yellow
    }
}

class DVC: UIViewController, Eatable {
    
    var firstTableView: UITableView = UITableView()
    let resuerId: String = "firstCell"
    let viewModel = DemoViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "测试响应式框架"
        createTableView()
        bindViewModel()
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 260, width: 300, height: 44)
        btn.tag = 24
        btn.setTitle("响应式框架+面向协议编程", for: .normal)
        view.addSubview(btn)
        btn.rx.tap
            .subscribe(onNext: {
                self.eat()
            })
        .disposed(by: disposeBag)
        
        let taps: Observable<Void> = btn.rx.tap.asObservable()
        taps.subscribe(onNext: {print("点击了按钮")})
        
        _ = Observable<String>.create { (obserber) -> Disposable in
            obserber.onNext("Cooci -  框架班级")
            return Disposables.create()
        }.subscribe(onNext: { (text) in
            print("订阅到:\(text)")
        })
    }
}

extension DVC {
    func createTableView() -> Void {
        view.backgroundColor = UIColor.white
        firstTableView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 260)
        view.addSubview(firstTableView)
        firstTableView.backgroundColor = UIColor.orange
        firstTableView.register(UITableViewCell.self, forCellReuseIdentifier: resuerId)
    }
    
    func bindViewModel() -> Void {
        //此方法将viewModel与tableView进行绑定
        viewModel.infoAry.bind(to: firstTableView.rx.items(cellIdentifier:resuerId)){
            row,model,cell in
            //cell的具体显示内容可在此处自定义
            cell.textLabel?.text = "firstKey \(model.firstKey), secondKey \(model.secondKey), row = \(row)"
        }.disposed(by: disposeBag)
        
        //点击cell的响应事件
        firstTableView.rx.modelSelected(DemoModel.self).subscribe(onNext: { (model) in
            print("select \(model.firstKey)")
        }).disposed(by: disposeBag)
    }
}

struct DemoModel {
    var firstKey:String
    var secondKey:Int
    init(firstKey:String, secondKey:Int) {
        self.firstKey = firstKey
        self.secondKey = secondKey
    }
}

struct DemoViewModel {
    //结构体中的数组被包装成了Observable
    let infoAry = Observable.just([DemoModel(firstKey: "1-1", secondKey: 1),
                                   DemoModel(firstKey: "1-2", secondKey: 2),
                                   DemoModel(firstKey: "1-3", secondKey: 3),
                                   DemoModel(firstKey: "1-4", secondKey: 4)])
}

