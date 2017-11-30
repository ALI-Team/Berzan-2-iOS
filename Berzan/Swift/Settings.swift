//
//  Settings.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-06.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import RETableViewManager
import MessageUI
import Alamofire

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var manager: RETableViewManager? = nil
    var mailItem: RETableViewItem? = nil
    var classSelector: RETextItem? = nil
    
    override func viewDidLoad() {
        
        UITextField.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        UIToolbar.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        //iOS 8 & 9
        self.tabBarController?.tabBar.tintColor = UIColor.white
        
        //Tableview
        manager = RETableViewManager.init(tableView: self.tableView)
        
        let scheduleSection = RETableViewSection.init(headerTitle: NSLocalizedString("schedule", comment: ""))
        
        classSelector = RETextItem.init(title: NSLocalizedString("class", comment: ""), value: UserDefaults.standard.string(forKey: "default-class"))
        classSelector?.onChange = {item in
            UserDefaults.standard.set(item?.value, forKey: "default-class")
            UserDefaults.standard.synchronize()
        }
        classSelector?.onEndEditing = {item in
            self.tableView.resignFirstResponder()
            if UserDefaults.standard.bool(forKey: "logged-in") {
                let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                
                item?.accessoryType = .none
                item?.accessoryView = loading
                
                //Crashes if done instantly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    item?.reloadRow(with: .none)
                })
                
                loading.startAnimating()
                
                Alamofire.request("https://berzan.nu/login/mobilesetsettings.php", method: .post, parameters: ["tokenid": UserDefaults.standard.string(forKey: "tokenid") ?? "", "tokenkey": UserDefaults.standard.string(forKey: "tokenkey") ?? "", "classid": self.classSelector?.value ?? ""], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {response in
                    
                    let status = response.result.value as? NSDictionary
                    
                    if (status!["status"] as! Int) == 1 {
                        
                        item?.accessoryView = nil
                        item?.accessoryType = .checkmark
                        
                        item?.reloadRow(with: .none)
                        
                    } else {
                        let errorController = UIAlertController.init(title: NSLocalizedString("connection-error", comment: ""), message: NSLocalizedString("check-internet", comment: ""), preferredStyle: .alert)
                        errorController.addAction(UIAlertAction.init(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        
                        self.present(errorController, animated: true, completion: nil)
                    }
                })
            }
        }
        classSelector?.autocorrectionType = .no
        classSelector?.autocapitalizationType = .none
        
        let nextWeek = REBoolItem.init(title: NSLocalizedString("next-week", comment: ""), value: UserDefaults.standard.bool(forKey: "next-week"))
        nextWeek?.switchValueChangeHandler = {_ in
            UserDefaults.standard.set(nextWeek?.value, forKey: "next-week")
            UserDefaults.standard.synchronize()
        }
        
        scheduleSection?.addItem(classSelector)
        scheduleSection?.addItem(nextWeek)
        
        let aboutSection = RETableViewSection.init(headerTitle: NSLocalizedString("about", comment: ""))
        
        mailItem = RETableViewItem.init(title: NSLocalizedString("mail-dev", comment: ""), accessoryType: .none, selectionHandler: {item in
            
            item?.deselectRow(animated: true)
            
            let mailComposer = MFMailComposeViewController.init()
            
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Berzan-Appen")
            mailComposer.setToRecipients(["lukjan1999@gmail.com"])
            mailComposer.setMessageBody("", isHTML: false)
            
            self.present(mailComposer, animated: true, completion: nil)
        })
        
        aboutSection?.addItem(mailItem)
        
        aboutSection?.addItem(RETableViewItem.init(title: NSLocalizedString("credits", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {_ in
            self.navigationController?.pushViewController(CreditsViewController.init(), animated: true)
        }))
        
        aboutSection?.footerTitle = "Berzan \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String)) \(NSLocalizedString("by-aliteam", comment: ""))"
        
        manager?.addSection(scheduleSection)
        manager?.addSection(aboutSection)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        classSelector?.value = UserDefaults.standard.string(forKey: "default-class")
        classSelector?.accessoryType = .none
        classSelector?.accessoryView = nil
        classSelector?.reloadRow(with: .none)
        
        mailItem?.accessoryType = .none
        mailItem?.reloadRow(with: .none)
        
        super.viewWillAppear(true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
        
        if result == MFMailComposeResult.sent {
            mailItem?.accessoryType = .checkmark
            mailItem?.reloadRow(with: .none)
        }
    }
}

class CreditsViewController: UITableViewController {
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        self.title = NSLocalizedString("credits", comment: "")
        
        manager = RETableViewManager.init(tableView: tableView)
        
        let mainSection = RETableViewSection.init()
        
        mainSection.headerView = UIView.init()
        mainSection.footerView = UIView.init()
        
        tableView.tableHeaderView = UIView.init()
        tableView.tableFooterView = UIView.init()
        
        mainSection.addItem(RETableViewItem.init(title: "XLPagerStrip", accessoryType: .none, selectionHandler: {item in
            
            guard let url = URL(string: "https://github.com/xmartlabs/XLPagerTabStrip") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            item?.deselectRow(animated: true)
        }))
        
        mainSection.addItem(RETableViewItem.init(title: "KingFisher", accessoryType: .none, selectionHandler: {item in
            
            guard let url = URL(string: "https://github.com/onevcat/Kingfisher") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            item?.deselectRow(animated: true)
        }))
        
        mainSection.addItem(RETableViewItem.init(title: "RMPickerViewController", accessoryType: .none, selectionHandler: {item in
            
            guard let url = URL(string: "https://github.com/CooperRS/RMPickerViewController") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            item?.deselectRow(animated: true)
        }))
        
        mainSection.addItem(RETableViewItem.init(title: "RETableViewManager", accessoryType: .none, selectionHandler: {item in
            
            guard let url = URL(string: "https://github.com/romaonthego/RETableViewManager") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            item?.deselectRow(animated: true)
        }))
        
        mainSection.addItem(RETableViewItem.init(title: "Alamofire", accessoryType: .none, selectionHandler: {item in
            
            guard let url = URL(string: "https://github.com/Alamofire/Alamofire") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            item?.deselectRow(animated: true)
        }))
        
        manager?.addSection(mainSection)
        
        super.viewDidLoad()
    }
}
