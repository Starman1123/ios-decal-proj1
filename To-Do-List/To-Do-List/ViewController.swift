//
//  ViewController.swift
//  To-Do-List
//
//  Created by Sheng Wang on 9/17/15.
//  Copyright © 2015 Sheng Wang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, NSFetchedResultsControllerDelegate {
    
    let cellIdentifier = "cellIdentifier"
    var tableView: UITableView!
    var itemList = [NSManagedObject]()
    var completedItemList = [NSManagedObject]()
    var firstLoaded: Bool = true
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
        tableView.frame = UIScreen.mainScreen().bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(SWTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        
        // set title
        self.title = "To-Do Items"
        
        // set plus button
        let plusButton:UIBarButtonItem = UIBarButtonItem(title: "New Item", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("plusButtonPressed"))
        let font: UIFont? = UIFont(name: "Arial", size: 16)
        plusButton.setTitleTextAttributes([NSFontAttributeName:font!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = plusButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        getItemList()
        getCompletedItemList()
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        getCompletedItemList()
    }
    
    func getItemList() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        let req: NSFetchRequest = NSFetchRequest(entityName: "Item")
        req.returnsObjectsAsFaults = false
        var results: NSArray = NSArray()
        do {
            try results = context.executeFetchRequest(req)
        } catch {
            let err = error as NSError
            print("\(err), \(err.userInfo)")
            abort()
        }
        if (results.count>0){
            self.itemList = results as! [NSManagedObject]
            print("self.itemList is \(self.itemList)")
            //self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
    
    func getCompletedItemList() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        let req: NSFetchRequest = NSFetchRequest(entityName: "CompletedItem")
        req.returnsObjectsAsFaults = false
        var results: NSArray = NSArray()
        do {
            try results = context.executeFetchRequest(req)
            if (results.count>0){
                self.completedItemList = results as! [NSManagedObject]
                print("completedItemList is \(self.completedItemList)")
                //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        } catch {
            let err = error as NSError
            print("\(err), \(err.userInfo)")
            abort()
        }
    }
    
    func getUtilityButtons()->NSMutableArray{
        let utilityButtons: NSMutableArray = NSMutableArray()
        utilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.07, green: 0.75, blue: 0.16, alpha: 1.0), icon: UIImage(named: "check.png"))
        utilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), icon: UIImage(named: "cross.png"))
        return utilityButtons
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {
            return itemList.count
        }
        else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section==0 {
            return "To-do list"
        }
        else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView?.dequeueReusableCellWithIdentifier(cellIdentifier) as! SWTableViewCell
            cell.delegate = self
            cell.rightUtilityButtons = getUtilityButtons() as [AnyObject]
            cell.textLabel!.text = itemList[indexPath.row].valueForKey("content") as? String
            cell.tag = indexPath.row
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Items completed in the past 24 hours"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==1 {
            let vc = StatsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        if index==0 {
            print("completed!")
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("CompletedItem", inManagedObjectContext: self.managedObjectContext)
            newItem.setValue(self.itemList[cell.tag].valueForKey("content"), forKey: "content")
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            newItem.setValue(date, forKey: "rawDate")
            newItem.setValue(formatter.stringFromDate(date), forKey: "date")
            deleteItemWithIndexPath(NSIndexPath(forRow: cell.tag, inSection: 0))
            getCompletedItemList()
            do {
                try context.save()
            } catch {
                let err = error as NSError
                print("\(err), \(err.userInfo)")
                abort()
            }
        }
        else {
            print("deleted!")
            deleteItemWithIndexPath(NSIndexPath(forRow: cell.tag, inSection: 0))
        }
    }
    
    func deleteItemWithIndexPath(indexPath: NSIndexPath) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        context.deleteObject(self.itemList[indexPath.row])
        self.itemList.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    

    
    func plusButtonPressed() {
        let vc:AddItemViewController = AddItemViewController()
        let nc:UINavigationController = UINavigationController()
        nc.pushViewController(vc, animated: false)
        self.presentViewController(nc, animated: true, completion: nil)
        self.firstLoaded = false
    }
}

