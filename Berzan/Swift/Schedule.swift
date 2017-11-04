//
//  ScheduleWrapperController.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-04.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class ScheduleWrapperController:ButtonBarPagerTabStripViewController {
    
    //General view setup
    override func viewDidLoad() {
        setupTabs()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Tab setup
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [ScheduleViewController(title:"V. 69"), ScheduleViewController(title:"Mån"), ScheduleViewController(title:"Tis"), ScheduleViewController(title:"Ons"), ScheduleViewController(title:"Tors"), ScheduleViewController(title:"Fre")]
    }
    
    func setupTabs() {
        settings.style.buttonBarBackgroundColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
        settings.style.buttonBarItemBackgroundColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
        settings.style.selectedBarBackgroundColor = UIColor.white
    }
}

class ScheduleViewController:UIViewController, IndicatorInfoProvider {
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = generateRandomColor()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:self.title)
    }
}
