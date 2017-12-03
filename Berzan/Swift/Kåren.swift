//
//  Kåren.swift
//  Berzan
//
//  Created by Luka Janković on 2017-12-02.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import AVFoundation
import RETableViewManager
import Kingfisher
import QRCodeReader
import Alamofire
import XLPagerTabStrip
import MBProgressHUD

class loginViewController: UITableViewController, IndicatorInfoProvider {
    
    var manager: RETableViewManager? = nil
    var user: RETextItem? = nil
    var pass: RETextItem? = nil
    
    override func viewDidLoad() {
        
        UITextField.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        UIToolbar.appearance().tintColor = self.navigationController?.navigationBar.barTintColor
        
        manager = RETableViewManager.init(tableView: self.tableView)
        
        user = RETextItem(title: "", value: "", placeholder: NSLocalizedString("username", comment: ""))
        pass = RETextItem(title: "", value: "", placeholder: NSLocalizedString("password", comment: ""))
        
        pass?.secureTextEntry = true
        pass?.returnKeyType = .go
        
        let login = RETableViewItem(title: NSLocalizedString("login", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            
            item?.deselectRow(animated: true)
            
            self.login()
        })
        
        pass?.onReturn = {_ in
            self.login()
        }
        
        let inputs = RETableViewSection()
        inputs.addItem(user)
        inputs.addItem(pass)
        
        let button = RETableViewSection()
        button.addItem(login)
        
        manager?.addSection(inputs)
        manager?.addSection(button)
        
        super.viewDidLoad()
    }
    
    func login() {
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
                                    UserDefaults.standard.set(userinfo!["rank"], forKey: "rank")
                                    
                                    if (userinfo!["classid"] as! String) != "" {
                                        UserDefaults.standard.set(userinfo!["classid"], forKey: "default-class")
                                    }
                                    
                                    UserDefaults.standard.synchronize()
                                    
                                    self.navigationController?.setViewControllers([(self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "kåren"))!], animated: true)
                                    
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
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("login", comment: ""))
    }
}

class registerViewController: UITableViewController, IndicatorInfoProvider {
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        manager = RETableViewManager.init(tableView: self.tableView)
        
        let fname = RETextItem(title: NSLocalizedString("fname", comment: ""), value: "")
        let lname = RETextItem(title: NSLocalizedString("lname", comment: ""), value: "")
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
        
        let register = RETableViewItem(title: NSLocalizedString("register", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            item?.deselectRow(animated: true)
            
            if fname?.value != "" && lname?.value != "" && user?.value != "" && pass?.value != "" && pass2?.value != "" && klass?.value != "" && city?.value != "" && birthYear?.value != "" && phone?.value != "" && mail?.value != "" && code?.value != "" {
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                self.tableView.resignFirstResponder()
                self.view.window?.isUserInteractionEnabled = false
                
                //username=%@&fname=%@&lname=%@&password=%@&password2=%@&invcode=%@&classid=%@&tel=%@&city=%@&sex=%@&byear=%@&email=%@
                
                var sex = ""
                
                switch gender?.value {
                case 0?:
                    sex = "M"
                    break
                case 1?:
                    sex = "F"
                    break
                case 2?:
                    sex = "0"
                    break
                default:
                    break
                }
                
                var params = [String: String]()
                params = ["username": user?.value as! String, "fname": fname?.value as! String, "lname": lname?.value as! String, "password": pass?.value as! String, "password2": pass2?.value as! String, "invcode": code?.value as! String, "classid": klass?.value as! String, "tel": phone?.value as! String, "city": city?.value as! String, "sex": sex as! String, "byear": birthYear?.value as! String, "email": mail?.value as! String]
                print(params)
                
                Alamofire.request("https://berzan.nu/login/mobileregister.php", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {response in
                    print(response)
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.view.window?.isUserInteractionEnabled = true
                    
                    let responseDict = response.result.value as! NSDictionary
                    
                    switch responseDict["status"]! as! NSNumber {
                    case -1:
                        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrong-code", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    case 0:
                        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("user-taken", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    case -2:
                        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("wrong-password", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    case -3:
                        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("old-code", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    case 1:
                        let alert = UIAlertController(title: NSLocalizedString("success", comment: ""), message: NSLocalizedString("register-success-message", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                    default:
                        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("unknown-error", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                let empty = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("empty-values", comment: ""), preferredStyle: .alert)
                empty.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                self.present(empty, animated: true, completion: nil)
            }
        })
        
        let inputs = RETableViewSection()
        inputs.addItem(fname)
        inputs.addItem(lname)
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Check if already logged in
        if UserDefaults.standard.bool(forKey: "logged-in") {
            self.navigationController?.setViewControllers([(self.storyboard?.instantiateViewController(withIdentifier: "kåren"))!], animated: false)
        }
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

class Kåren: UITableViewController, RETableViewManagerDelegate, QRCodeReaderViewControllerDelegate {
    
    var manager: RETableViewManager? = nil
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Tableview setup
        manager = RETableViewManager.init(tableView: self.tableView)
        manager?.delegate = self
        let main = RETableViewSection.init()
        
        let events = RETableViewItem(title: NSLocalizedString("events", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            
        })
        
        let card = RETableViewItem(title: NSLocalizedString("card", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "card"))!, animated: true)
        })
        
        main.addItem(events)
        main.addItem(card)
        
        manager?.addSection(main)
        
        if UserDefaults.standard.integer(forKey: "rank") > 0 {
            
            let styrelsen = RETableViewSection(headerTitle: NSLocalizedString("styrelsen", comment: ""))
            
            let scan = RETableViewItem(title: NSLocalizedString("scan", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
                self.readerVC.delegate = self
                
                // Or by using the closure pattern
                self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                    
                    let url = "https://berzan.nu/login/card/verifycard.php?token=\(result?.value ?? "")"
                    
                    Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {response in
                        
                        let responseDict = response.result.value as! NSDictionary
                        
                        if let userInfo = responseDict["user"] as? NSDictionary {
                            let resultVC = UIAlertController(title: NSLocalizedString("verified", comment: ""), message: "\(NSLocalizedString("name", comment: "")): \(userInfo["firstname"]!) \(userInfo["lastname"]!)\n\(NSLocalizedString("class", comment: "")): \(userInfo["classid"]!)\n\(NSLocalizedString("code", comment: "")): \(responseDict["safecode"]!)", preferredStyle: .alert)
                            resultVC.addAction(UIAlertAction(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                            self.present(resultVC, animated: true, completion: nil)
                        }
                    })
                }
                
                // Presents the readerVC as modal form sheet
                self.readerVC.modalPresentationStyle = .formSheet
                self.present(self.readerVC, animated: true, completion: nil)
            })
            
            styrelsen?.addItem(scan)
            
            manager?.addSection(styrelsen)
        }
        
        let logoutSection = RETableViewSection()
        let logout = RETableViewItem(title: NSLocalizedString("logout", comment: ""), accessoryType: .none, selectionHandler: {item in
            UserDefaults.standard.removeObject(forKey: "rank")
            UserDefaults.standard.removeObject(forKey: "tokenkey")
            UserDefaults.standard.removeObject(forKey: "tokenid")
            UserDefaults.standard.removeObject(forKey: "logged-in")
            UserDefaults.standard.synchronize()
            
            self.navigationController?.setViewControllers([(self.storyboard?.instantiateViewController(withIdentifier: "kåren-login"))!], animated: true)
        })
        
        logoutSection.addItem(logout)
        
        manager?.addSection(logoutSection)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView!, willLoad cell: UITableViewCell!, forRowAt indexPath: IndexPath!) {
        if UserDefaults.standard.integer(forKey: "rank") > 0 {
            if indexPath.section == 2 {
                cell.textLabel?.textColor = UIColor.red
            }
        } else {
            if indexPath.section == 1 {
                cell.textLabel?.textColor = UIColor.red
            }
        }
    }
}

class CardViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = NSLocalizedString("card", comment: "")
        
        cardView?.kf.indicatorType = .activity
        cardView?.kf.setImage(with: URL(string: "https://berzan.nu/login/card/card.php?tokenid=\(UserDefaults.standard.string(forKey: "tokenid") ?? "")&tokenkey=\(UserDefaults.standard.string(forKey: "tokenkey") ?? "")"))
        
        super.viewWillAppear(animated)
    }
}
