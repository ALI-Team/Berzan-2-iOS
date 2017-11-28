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
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        manager = RETableViewManager.init(tableView: self.tableView)
        
        let name = RETextItem(title: NSLocalizedString("name", comment: ""), value: "")
        let user = RETextItem(title: NSLocalizedString("username", comment: ""), value: "")
        let pass = RETextItem(title: NSLocalizedString("password", comment: ""), value: "")
        let pass2 = RETextItem(title: NSLocalizedString("confirm-password", comment: ""), value: "")
        let klass = RETextItem(title: NSLocalizedString("class", comment: ""), value: "")
        let gender = RESegmentedItem(title: NSLocalizedString("gender", comment: ""), segmentedControlTitles: [NSLocalizedString("man", comment: ""), NSLocalizedString("woman", comment: ""), NSLocalizedString("other", comment: "")], value: 0)
        let city = RETextItem(title: NSLocalizedString("city", comment: ""), value: "")
        let birthYear = RENumberItem(title: NSLocalizedString("birth-year", comment: ""), value: "", placeholder: "", format: "XXXX")
        let phone = RENumberItem(title: NSLocalizedString("phone-number", comment: ""), value: "", placeholder: "", format: "XXX-XXX XX XX")
        let mail = RETextItem(title: NSLocalizedString("mail", comment: ""), value: "")
        let code = RETextItem(title: NSLocalizedString("code", comment: ""), value: "")
        
        gender?.tintColor = UITextField.appearance().tintColor
        birthYear?.textAlignment = .left
        
        pass?.secureTextEntry = true
        pass2?.secureTextEntry = true
        
        let register = RETableViewItem(title: NSLocalizedString("register", comment: ""))
        
        let inputs = RETableViewSection()
        inputs.addItem(name)
        inputs.addItem(user)
        inputs.addItem(pass)
        inputs.addItem(pass2)
        inputs.addItem(klass)
        inputs.addItem(gender)
        inputs.addItem(city)
        inputs.addItem(birthYear)
        inputs.addItem(phone)
        inputs.addItem(mail)
        inputs.addItem(code)
        
        let button = RETableViewSection()
        button.addItem(register)
        
        manager?.addSection(inputs)
        manager?.addSection(button)
        
        super.viewDidLoad()
    }
    
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
