//
//  Kåren-Login.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-27.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RETableViewManager

class loginViewController: UITableViewController, IndicatorInfoProvider {
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        UITextField.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        UIToolbar.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        
        manager = RETableViewManager.init(tableView: self.tableView)
        
        let user = RETextItem(title: "", value: "", placeholder: NSLocalizedString("username", comment: ""))
        let pass = RETextItem(title: "", value: "", placeholder: NSLocalizedString("password", comment: ""))
        
        pass?.secureTextEntry = true
        
        let login = RETableViewItem(title: NSLocalizedString("login", comment: ""))
        
        let inputs = RETableViewSection()
        inputs.addItem(user)
        inputs.addItem(pass)
        
        let button = RETableViewSection()
        button.addItem(login)
        
        manager?.addSection(inputs)
        manager?.addSection(button)
        
        super.viewDidLoad()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("login", comment: ""))
    }
}

class registerViewController: UITableViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("register", comment: ""))
    }
}

class loginViewControllerWrapper: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        //UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        setupTabs()
        
        super.viewDidLoad()
    }
    
    func setupTabs() {
        settings.style.buttonBarBackgroundColor = self.navigationController?.navigationBar.barTintColor
        settings.style.buttonBarItemBackgroundColor = settings.style.buttonBarBackgroundColor
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarItemLeftRightMargin = 2
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [loginViewController.init(style: .grouped), registerViewController.init(style: .grouped)]
    }
}
