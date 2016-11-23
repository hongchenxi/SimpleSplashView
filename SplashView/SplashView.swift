//
//  SplashView.swift
//  SplashView
//
//  Created by 晨希 on 11/23/16.
//  Copyright © 2016 cx. All rights reserved.
//

import UIKit

class SplashView: UIView {

    static let IMG_URL = "splash_img_url"
    static let ACT_URL = "splash_act_url"
    static let IMG_PATH = String(format: "%@/Documents/splash_image.jpg", NSHomeDirectory())
    
    let screenW = UIScreen.main.bounds.size.width
    let screenH = UIScreen.main.bounds.size.height
    let statusH = UIApplication.shared.statusBarFrame.height
    
    let btnW: CGFloat = 44;
    let btnH: CGFloat = 44;
    let btnMargin: CGFloat = 16.0;
    
    var duration: TimeInterval = 6.0 {
        didSet {
            skipButton?.setTitle("跳过\n\(duration) s",for: UIControlState())
        }
    }
    
    var skipButton: UIButton?
    var imageView: UIImageView?
    
    var imageUrl: String?
    var actionUrl: String?
    var timer: Timer?
    
    var tapSplashImageBlock: ((_ actionUrl: String?) -> Void)?
    var splashViewDissmissBlock: ((_ initiativeDismiss: Bool) -> Void)?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
        initComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showSplashView(_ duration: TimeInterval = 6.0, defaultImage: UIImage?, tapSplashImageBlock:((_ actionUrl: String?) -> Void)?, splashViewDismissBlock:((_ initiativeDismiss: Bool) -> Void)?) {
        
        let splashView = SplashView();
        splashView.tapSplashImageBlock = tapSplashImageBlock
        splashView.splashViewDissmissBlock = splashViewDismissBlock
        splashView.duration = duration
        
        if isExitsSplashData() {
            splashView.imageView?.image = UIImage(contentsOfFile: SplashView.IMG_PATH)
        } else if let defaultImage = defaultImage {
            splashView.imageView?.image = defaultImage
        }
        
        UIApplication.shared.delegate?.window!?.addSubview(splashView)
    }
    
    class func updateSplashData(_ imgUrl: String?, actUrl: String?) {
        if nil == imgUrl {
            return
        }
        
        UserDefaults.standard.setValue(imgUrl, forKey: IMG_URL)
        UserDefaults.standard.setValue(actUrl, forKey: ACT_URL)
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            let imageUrl = URL(string: imgUrl!)
                if let imageUrl = imageUrl {
                    let data = try? Data(contentsOf: imageUrl)
                    if let data = data {
                        let image = UIImage(data: data)
                        if let image = image {
                            try?UIImagePNGRepresentation(image)?.write(to: URL(fileURLWithPath:IMG_PATH), options: [.atomic])
                        }
                    }
                }
        }
    }
    
    class func isExitsSplashData() -> Bool {
        let latestImgUrl = UserDefaults.standard.value(forKey: IMG_URL) as? String
        let isFileExists = FileManager.default.fileExists(atPath: IMG_PATH)
        return nil != latestImgUrl && isFileExists
    }
    

    func initComponents() {
        imageUrl = UserDefaults.standard.value(forKey: SplashView.IMG_URL) as? String
        actionUrl = UserDefaults.standard.value(forKey: SplashView.ACT_URL) as? String
        
        self.backgroundColor = UIColor.white
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
        imageView?.isUserInteractionEnabled = true
        let recognize = UITapGestureRecognizer(target: self, action: #selector(tapImageViewAction))
        imageView?.addGestureRecognizer(recognize)
        self.addSubview(imageView!)
        
        skipButton = UIButton(frame: CGRect(x: screenW - btnW - btnMargin, y: btnMargin, width: btnW, height: btnH))
        skipButton?.layer.cornerRadius = btnW / 2
        skipButton?.clipsToBounds = true
        skipButton?.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
        skipButton?.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        skipButton?.titleLabel?.textAlignment = .center
        skipButton?.titleLabel?.numberOfLines = 2
        skipButton?.setTitle("跳过\n\(duration) s", for: UIControlState())
        skipButton?.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        self.addSubview(skipButton!)
        
        setupTimer()
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCycleAction), userInfo: nil, repeats: true)
    }
    
    func timerCycleAction() {
        if 0 == duration {
            dismissSplashView(false)
        } else {
            duration -= 1
        }
    }
    
    func dismissSplashView(_ initiativeDismiss: Bool) {
        stopTimer()
        
        UIView.animate(withDuration: 0.6, animations: { 
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (finished) in
                self.removeFromSuperview()
                if let splashViewDissmissBlock = self.splashViewDissmissBlock {
                    splashViewDissmissBlock(initiativeDismiss)
                }
        }
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func skipAction() {
        dismissSplashView(true)
    }
    
    func tapImageViewAction() {
        if let tapSplashImageBlock = self.tapSplashImageBlock {
            self.skipAction()
            tapSplashImageBlock(self.actionUrl)
        }
    }
    
}
