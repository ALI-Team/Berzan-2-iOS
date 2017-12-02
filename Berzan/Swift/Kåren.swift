//
//  Kåren.swift
//  Berzan
//
//  Created by Luka Janković on 2017-12-02.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import RETableViewManager

class Kåren: UITableViewController {
    
    var manager: RETableViewManager? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Tableview setup
        manager = RETableViewManager.init(tableView: self.tableView)
        let main = RETableViewSection.init()
        
        let events = RETableViewItem(title: NSLocalizedString("events", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            
        })
        
        let card = RETableViewItem(title: NSLocalizedString("card", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
            
        })
        
        main.addItem(events)
        main.addItem(card)
        
        manager?.addSection(main)
        
        if UserDefaults.standard.integer(forKey: "rank") > 0 {
            
            let styrelsen = RETableViewSection(headerTitle: NSLocalizedString("styrelsen", comment: ""))
            
            let scan = RETableViewItem(title: NSLocalizedString("scan", comment: ""), accessoryType: .disclosureIndicator, selectionHandler: {item in
                
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
