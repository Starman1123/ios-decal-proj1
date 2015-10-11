//
//  ViewController.swift
//  To-Do-List
//
//  Created by Sheng Wang on 9/17/15.
//  Copyright © 2015 Sheng Wang. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "cellIdentifier"
    var tableView: UITableView!
    var itemList = [NSManagedObject]()
    var firstLoaded: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView()
        tableView.frame = UIScreen.mainScreen().bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        
        // set title
        self.title = "To-Do Items"
        
        // set plus button
        let plusButton:UIBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("plusButtonPressed"))
        let font: UIFont? = UIFont(name: "Arial", size: 30)
        plusButton.setTitleTextAttributes([NSFontAttributeName:font!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = plusButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = self.tableView?.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        cell!.textLabel!.text = itemList[indexPath.row].valueForKey("content") as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        if editingStyle == UITableViewCellEditingStyle.Delete {
            context.deleteObject(self.itemList[indexPath.row])
            self.itemList.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func plusButtonPressed() {
        let vc:AddItemViewController = AddItemViewController()
        let nc:UINavigationController = UINavigationController()
        nc.pushViewController(vc, animated: false)
        self.presentViewController(nc, animated: true, completion: nil)
        self.firstLoaded = false
    }
}

