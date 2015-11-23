//
//  StatsViewController.swift
//  To-Do-List
//
//  Created by Sheng Wang on 11/22/15.
//  Copyright © 2015 Sheng Wang. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let cellIdentifier = "cellIdentifier"
    var tableView: UITableView!
    var completedItemList = [NSManagedObject]()
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        let req: NSFetchRequest = NSFetchRequest(entityName: "CompletedItem")
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
            self.completedItemList = results as! [NSManagedObject]
            var newCompletedItemList = [NSManagedObject]()
            for obj: NSManagedObject in self.completedItemList {
                let hours = NSCalendar.currentCalendar().components(.Hour, fromDate: obj.valueForKey("rawDate") as! NSDate, toDate: NSDate(), options: []).hour
                if hours<24 {
                    newCompletedItemList.append(obj)
                }
                else {
                    context.deleteObject(obj)
                }
            }
            
            do {
                try context.save()
                
            } catch {
                print("Unresolved Core Data Save error")
                abort()
            }
            
            self.completedItemList = newCompletedItemList
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.completedItemList.count) completed items"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.completedItemList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = self.completedItemList[indexPath.row].valueForKey("content") as? String
        cell.detailTextLabel?.text = self.completedItemList[indexPath.row].valueForKey("date") as? String
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
