//
//  AddItemViewController.swift
//  To-Do-List
//
//  Created by Sheng Wang on 10/9/15.
//  Copyright © 2015 Sheng Wang. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var cancelItem: UIBarButtonItem = UIBarButtonItem()
    var addItem: UIBarButtonItem = UIBarButtonItem()
    var textField: UITextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        self.cancelItem = UIBarButtonItem(title: "cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonClicked"))
        self.addItem = UIBarButtonItem(title: "add", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addButtonClicked"))
        self.navigationItem.leftBarButtonItem = cancelItem
        self.navigationItem.rightBarButtonItem = addItem
        
        let width = UIScreen.mainScreen().bounds.width
        self.textField = UITextField(frame: CGRectMake(10, 80, width-20, 40))
        self.textField.placeholder = "Enter to-do item here"
        self.textField.font = UIFont.systemFontOfSize(15)
        self.textField.borderStyle = UITextBorderStyle.RoundedRect
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        self.view.addSubview(self.textField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonClicked() {
        if self.textField.text == "" {
            let alertController: UIAlertController = UIAlertController(title: "Error", message: "Cannot add an empty task", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.managedObjectContext)
            newItem.setValue(self.textField.text, forKey: "content")
            do {
                try self.managedObjectContext.save()
            } catch {
                let err = error as NSError
                print("\(err), \(err.userInfo)")
                abort()
            }
            print(newItem)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
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
