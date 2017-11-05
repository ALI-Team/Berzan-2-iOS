//
//  ScheduleWrapperController.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-04.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Kingfisher
import RMPickerViewController
import RETableViewManager

class ClassListActionController: RMActionController<UITableView> {
    required override init?(style aStyle: RMActionControllerStyle, title aTitle: String?, message aMessage: String?, select selectAction: RMAction<UITableView>?, andCancel cancelAction: RMAction<UITableView>?) {
        super.init(style: aStyle, title: aTitle, message: aMessage, select: selectAction, andCancel: cancelAction)
        
        self.contentView = UITableView()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.white
        
        let bindings = ["contentView": self.contentView];
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[contentView(>=300)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[contentView(200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}

class ScheduleWrapperController:ButtonBarPagerTabStripViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var scheduleList = [ScheduleViewController]()
    var week: Int = 0
    
    //General view setup
    override func viewDidLoad() {
        setupTabs()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup week
        self.week = Calendar.current.component(.weekOfYear, from: Date())
        setWeek()
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        //iOS 8 & 9
        self.tabBarController?.tabBar.tintColor = UIColor.white
        
        /*
         *
         * REMINDER
         * ========
         * Scrolling to the day with moveToViewController(at index: Int) does not currently work with XLPagerStrip, waiting for a fix
         *
         */
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Tab setup
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        scheduleList = [ScheduleViewController(title:NSLocalizedString("week-prefix", comment: "")+" 35", index: 0), ScheduleViewController(title:NSLocalizedString("monday-short", comment: ""), index: 1), ScheduleViewController(title:NSLocalizedString("tuesday-short", comment: ""), index: 2), ScheduleViewController(title:NSLocalizedString("wednesday-short", comment: ""), index: 4), ScheduleViewController(title:NSLocalizedString("thursday-short", comment: ""), index: 8), ScheduleViewController(title:NSLocalizedString("friday-short", comment: ""), index: 16)]
        return scheduleList
    }
    
    func setupTabs() {
        settings.style.buttonBarBackgroundColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
        settings.style.buttonBarItemBackgroundColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarItemLeftRightMargin = 2
    }
    
    //Week picker
    @IBAction func selectWeek(_ sender: Any) {
        
        let cancelAction = RMAction<UIPickerView>(title: NSLocalizedString("cancel", comment:""), style:.cancel) { _ in
        }
        
        let thisWeekAction = RMAction<UIPickerView>(title: NSLocalizedString("this-week", comment:""), style:.done) { _ in
            self.week = Calendar.current.component(.weekOfYear, from: Date())
            self.setWeek()
            self.reloadSchedules()
        }
        
        let selectAction = RMAction<UIPickerView>(title: NSLocalizedString("select", comment:""), style:.done) { controller in
            self.week = controller.contentView.selectedRow(inComponent: 0)
            self.setWeek()
            self.reloadSchedules()
        }
        
        let actionController = RMPickerViewController(style:.white, title: "", message: "", select:selectAction, andCancel:cancelAction)!
        actionController.picker.delegate = self
        actionController.picker.dataSource = self
        actionController.disableBouncingEffects = true
        actionController.disableBlurEffects = true
        actionController.picker.selectRow(week - 1, inComponent: 0, animated: false)
        
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
    
    //Class picker
    @IBAction func selectClass(_ sender: Any) {
        
        let cancelAction = RMAction<UITableView>(title: NSLocalizedString("cancel", comment:""), style:.cancel) { _ in
        }
        
        let editAction = RMAction<UITableView>(title: NSLocalizedString("edit", comment:""), style:.done) { _ in
            
        }
        
        let selectAction = RMAction<UITableView>(title: NSLocalizedString("select", comment:""), style:.done) { controller in
        }
        
        let actionController = ClassListActionController(style:.white, title: NSLocalizedString("select-class-title", comment: ""), message:"", select:selectAction, andCancel:cancelAction)!
        
        actionController.disableBlurEffects = true
        actionController.disableBouncingEffects = true
        actionController.addAction(editAction!)
        actionController.view.tintColor = UIColor(red:0.53, green:0.08, blue:0.22, alpha:1.0)
    
        let classListTable = actionController.contentView
        let classListManager = RETableViewManager.init(tableView: classListTable)
        
        let baseSection = RETableViewSection.init()
        
        baseSection.addItem(RETableViewItem.init(title: "Test"))
        baseSection.addItem(RETableViewItem.init(title: "Test"))
        baseSection.addItem(RETableViewItem.init(title: "Test"))
        baseSection.addItem(RETableViewItem.init(title: "Test"))
        
        classListManager?.addSection(baseSection)
        
        //Again...
        tabBarController?.present(actionController, animated: true, completion:nil)
    }
    
    //Other
    func setWeek() {
        for scheduleView: ScheduleViewController in scheduleList {
            scheduleView.week = self.week
        }
    }
    
    func reloadSchedules() {
        for scheduleView: ScheduleViewController in scheduleList {
            scheduleView.loadSchedule()
        }
    }
}

class ScheduleViewController:UIViewController, IndicatorInfoProvider {
    
    var itemIndex: Int
    var itemTitle: String
    var scheduleView: UIImageView?
    var week: Int
    
    init(title: String, index: Int) {
        itemTitle = title
        itemIndex = index
        scheduleView = nil
        week = 0
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if scheduleView?.image == nil {
            loadSchedule()
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:itemTitle)
    }
    
    func initializeInterface() {
        
        //Imageview
        if scheduleView == nil {
            scheduleView = UIImageView.init()
            
            view.addSubview(scheduleView!)
        }
        
        scheduleView?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: scheduleView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scheduleView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scheduleView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 45))
        view.addConstraint(NSLayoutConstraint(item: scheduleView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    func loadSchedule() {
        
        view.layoutIfNeeded()
        
        if scheduleView?.bounds != nil {
            let viewHeight = Int((scheduleView?.bounds.height)!)
            let viewWidth = Int((scheduleView?.bounds.width)!)
            
            scheduleView?.kf.indicatorType = .activity
            scheduleView?.kf.setImage(with: URL(string: "http://www.novasoftware.se/ImgGen/schedulegenerator.aspx?format=png&schoolid=89920/\(NSLocalizedString("schedule-lan", comment: ""))&type=-1&id=na15c&period=&week=\(week)&mode=0&printer=0&colors=32&head=0&clock=0&foot=0&day=\(itemIndex)&width=\(viewWidth)&height=\(viewHeight)&maxwidth=\(viewWidth)&maxheight=\(viewHeight)"))
        }
    }
}
