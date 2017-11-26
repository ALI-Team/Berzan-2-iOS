//
//  SchoolFood.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-16.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import Alamofire
import RMPickerViewController

class SchoolFoodCell:UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var item0Label: UILabel!
    @IBOutlet weak var item1Label: UILabel!
    @IBOutlet weak var item2Label: UILabel!
    @IBOutlet weak var emoji0Label: UILabel!
    @IBOutlet weak var emoji1Label: UILabel!
    @IBOutlet weak var emoji2Label: UILabel!
}

class SchoolFood:UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var contentArray = [AnyObject]()
    var week = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Tableview setup
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(reloadTableView(_:)), for: .valueChanged)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        if self.contentArray.count == 0 {
            self.refreshControl!.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
            
            reloadTableView(self.refreshControl!)
        }
    }

    //UITableView Setup
    @IBAction func reloadTableView(_ sender: UIRefreshControl) {
        
        Alamofire.request("http://skolmaten.se/berzeliusskolan/?&offset=\(self.week)&limit=1&fmt=json").responseJSON(completionHandler: { responseObject in
            
            if let responseDict = responseObject.result.value as? NSDictionary {
                
                let weeksArray = responseDict["weeks"]! as! NSArray
                let currentWeek = weeksArray[0] as! NSDictionary
                
                self.contentArray = currentWeek["days"] as! Array
                
            } else {
                //Connection error
                let errorController = UIAlertController.init(title: NSLocalizedString("connection-error", comment: ""), message: NSLocalizedString("check-internet", comment: ""), preferredStyle: .alert)
                errorController.addAction(UIAlertAction.init(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                
                self.present(errorController, animated: true, completion: {
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                })
            }
            
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SchoolFoodCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            cell.dayLabel.text = NSLocalizedString("monday-short", comment: "")
            break
        case 1:
            cell.dayLabel.text = NSLocalizedString("tuesday-short", comment: "")
            break
        case 2:
            cell.dayLabel.text = NSLocalizedString("wednesday-short", comment: "")
            break
        case 3:
            cell.dayLabel.text = NSLocalizedString("thursday-short", comment: "")
            break
        case 4:
            cell.dayLabel.text = NSLocalizedString("friday-short", comment: "")
            break
        default:
            break
        }
        
        if contentArray.count > 0 {
            
            if let content = contentArray[indexPath.row]["items"]! as? NSArray {
                for i in 0...2 {
                    switch i {
                    case 0:
                        cell.item0Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                        cell.emoji0Label.text = emojiForLine(input: (content[i] as! String))
                        break
                    case 1:
                        cell.item1Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                        cell.emoji1Label.text = emojiForLine(input: (content[i] as! String))
                        break
                    case 2:
                        cell.item2Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                        cell.emoji2Label.text = emojiForLine(input: (content[i] as! String))
                        break
                    default:
                        break
                    }
                }
            } else {
                let error = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("food-fail", comment: ""), preferredStyle: .alert)
                error.addAction(UIAlertAction.init(title: NSLocalizedString("back", comment: ""), style: .cancel, handler: nil))
                self.present(error, animated: true, completion: nil)
            }
        }
        
        return cell
    }
    
    func emojiForLine(input: String) -> String {
        let tagRegex = "\\(([^,)]+)"
        
        print(input)
        
        if input.range(of: tagRegex, options: .regularExpression, range: nil, locale: nil) != nil {
            var tag = input[input.range(of: tagRegex, options: .regularExpression, range: nil, locale: nil)!]
            tag.remove(at: tag.startIndex)
            
            switch tag {
            case "Fågel":
                return "🐦"
            case "Fisk":
                return "🐟"
            case "Ko":
                return "🐄"
            case "Fläsk":
                return "🐖"
            case "Vegetariskt":
                return "🍏"
            default:
                return "b"
            }
        } else {
            return "a"
        }
    }
    
    @IBAction func changeWeek(_ sender: Any) {
        
        let cancelAction = RMAction<UIPickerView>(title: NSLocalizedString("cancel", comment:""), style:.cancel) { _ in
        }
        
        let thisWeekAction = RMAction<UIPickerView>(title: NSLocalizedString("this-week", comment:""), style:.done) { _ in
            self.week = 0
            self.refreshControl!.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height), animated: true)
            self.reloadTableView(self.refreshControl!)
        }
        
        let selectAction = RMAction<UIPickerView>(title: NSLocalizedString("select", comment:""), style:.done) { controller in
            self.week = (controller.contentView.selectedRow(inComponent: 0) + 1) - (Calendar.current.component(.weekOfYear, from: Date()))
            self.refreshControl!.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl!.frame.size.height), animated: true)
            self.reloadTableView(self.refreshControl!)
        }
        
        let actionController = RMPickerViewController(style:.white, title: "", message: "", select:selectAction, andCancel:cancelAction)!
        actionController.picker.delegate = self
        actionController.picker.dataSource = self
        actionController.disableBouncingEffects = true
        actionController.disableBlurEffects = true
        actionController.picker.selectRow(Calendar.current.component(.weekOfYear, from: Date()) + self.week - 1, inComponent: 0, animated: false)
        
        actionController.addAction(thisWeekAction!)
        
        actionController.view.tintColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
        
        //Don't ask...
        tabBarController?.present(actionController, animated: true, completion:nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 52
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row+1)
    }
}
