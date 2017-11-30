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
import MBProgressHUD
import Alamofire

class loginViewController: UITableViewController, IndicatorInfoProvider {
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        UITextField.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        UIToolbar.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        
        manager = RETableViewManager.init(tableView: self.tableView)
        
        let user = RETextItem(title: "", value: "", placeholder: NSLocalizedString("username", comment: ""))
        let pass = RETextItem(title: "", value: "", placeholder: NSLocalizedString("password", comment: ""))
        
        pass?.secureTextEntry = true
        
        let login = RETableViewItem(title: NSLocalizedString("login", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            
            
            item?.deselectRow(animated: true)
            
            if user?.value == "" || pass?.value == "" {
                let empty = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("empty-values", comment: ""), preferredStyle: .alert)
                empty.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                self.present(empty, animated: true, completion: nil)
            } else {
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                self.tableView.resignFirstResponder()
                self.view.window?.isUserInteractionEnabled = false
                
                Alamofire.request("https://berzan.nu/login/mobilelogin.php", method: .post, parameters: ["username":user?.value ?? "", "password":pass?.value ?? ""], encoding: URLEncoding.default).responseJSON(completionHandler: { response in
                    
                    if let responseDict = response.result.value as? NSDictionary {
                        
                        print(responseDict)
                        
                        if (responseDict["status"] as? Int) == 1 {
                            
                            let tokens = responseDict["tokens"] as? NSDictionary
                            
                            Alamofire.request("https://berzan.nu/login/jsonchecktokens.php", method: .post, parameters: ["tokenid":tokens!["tokenid"] ?? "", "tokenkey":tokens!["tokenkey"] ?? ""], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { result in
                                
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.view.window?.isUserInteractionEnabled = true
                                
                                if let responseDict2 = result.result.value as? NSDictionary {
                                    
                                    print(responseDict2)
                                    
                                    if (responseDict2["status"] as? Int) == 1 {
                                        print("logged in")
                                        
                                        let userinfo = responseDict2["user"] as? NSDictionary
                                        
                                        UserDefaults.standard.set(true, forKey: "logged-in")
                                        UserDefaults.standard.set(tokens!["tokenid"], forKey: "tokenid")
                                        UserDefaults.standard.set(tokens!["tokenkey"], forKey: "tokenkey")
                                        
                                        if (userinfo!["classid"] as! String) != "" {
                                            UserDefaults.standard.set(userinfo!["classid"], forKey: "default-class")
                                        }
                                        
                                        UserDefaults.standard.synchronize()
                                        
                                    } else {
                                        
                                        let error = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrong-login", comment: ""), preferredStyle: .alert)
                                        error.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                                        self.present(error, animated: true, completion: nil)
                                        
                                    }
                                    
                                } else {
                                    
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    self.view.window?.isUserInteractionEnabled = true
                                    
                                    let error = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrong-login", comment: ""), preferredStyle: .alert)
                                    error.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                                    self.present(error, animated: true, completion: nil)
                                }
                            })
                            
                        } else {
                            
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.view.window?.isUserInteractionEnabled = true
                            
                            let error = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrong-login", comment: ""), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.view.window?.isUserInteractionEnabled = true
                    } else {
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.view.window?.isUserInteractionEnabled = true
                        
                        let errorController = UIAlertController.init(title: NSLocalizedString("connection-error", comment: ""), message: NSLocalizedString("check-internet", comment: ""), preferredStyle: .alert)
                        errorController.addAction(UIAlertAction.init(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        
                        self.present(errorController, animated: true, completion: nil)
                    }
                })
            }
        })
        
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
