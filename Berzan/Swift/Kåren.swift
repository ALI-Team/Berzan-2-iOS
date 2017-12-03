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
