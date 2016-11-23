//
//  ViewController.swift
//  SplashView
//
//  Created by 晨希 on 11/23/16.
//  Copyright © 2016 cx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SplashView.updateSplashData("http://img5.duitang.com/uploads/item/201501/29/20150129224716_rQy8f.jpeg", actUrl: "https://www.baidu.com")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        SplashView.showSplashView(defaultImage:UIImage(named:"dog"), tapSplashImageBlock: { (actionUrl) in
            print("actionUrl：\(actionUrl)")
            }, splashViewDismissBlock: { (initiativeDismiss) in
            print("initiativeDismiss：\(initiativeDismiss)")
        })
    }
}

