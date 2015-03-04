//
//  TreatmentCourseViewController.swift
//  myTeeth
//
//  Created by David Canty on 02/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc protocol TreatmentCourseViewControllerDelegate: NSObjectProtocol {
optional func courseViewControllerDidFinishWithCourse(course: TreatmentCourse)
}

class TreatmentCourseViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

// MARK: - Properties

    let courseCellIdentifier = "CourseCellIdentifier"
    
    var managedObjectContext: NSManagedObjectContext
    var _fetchedResultsController: NSFetchedResultsController?
    var delegate: TreatmentCourseViewControllerDelegate?
    
    var selectedCourse: TreatmentCourse?
    var selectedCourseIndexPath: NSIndexPath?
    
// MARK: - IB Outlets
    
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var courseTableView: UITableView!
    
// MARK: - IB Actions
    
    @IBAction func addCourseTapped(sender: AnyObject) {
    
        if (courseNameTextField.text == "") {
            
            wobbleView(courseNameTextField)
            
        } else {
            
            let course:TreatmentCourse = NSEntityDescription.insertNewObjectForEntityForName("TreatmentCourse", inManagedObjectContext: managedObjectContext) as TreatmentCourse
            
            let uuid = NSUUID().UUIDString
            course.uniqueId = uuid;
            
            course.courseName = courseNameTextField.text;
            course.completed = false
            
            // Save the context
            var error:NSError?
            if (!managedObjectContext.save(&error)) {
                
                println("Unresolved error \(error) \(error?.userInfo)")
                abort()
            }
            
            courseNameTextField.text = ""
            courseNameTextField.resignFirstResponder()
        }
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        
        // Validation
        var isValidated = true
        
        if (self.selectedCourse == nil &&
            TreatmentCourse.numberOfTreatmentCourses() == 0) {
                
                isValidated = false
                wobbleView(courseNameTextField)
                
        } else if (self.selectedCourseIndexPath == nil) {
            
            isValidated = false
            wobbleView(courseTableView)
            
        }
        
        if (isValidated) {
            
            delegate?.courseViewControllerDidFinishWithCourse?(selectedCourse!)
        }
    }
    
// MARK: - Methods
    
    required init(coder aDecoder: NSCoder) {
        
        managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var error:NSError?
        if (!fetchedResultsController.performFetch(&error)) {
            
            println("Unresolved error \(error) \(error?.userInfo)")
            abort()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Check selected course row
        if let course = selectedCourse {
            
            selectedCourseIndexPath = fetchedResultsController.indexPathForObject(course)
        }
    }
    
// MARK: - Text Field
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Prevent space at beginning
        if (range.location == 0 && string == " ") {
            
            return false
        }
        
        // Enable backspace
        if (range.length > 0 && countElements(string) == 0) {
            
            return true
        }
        
        // Allowed characters
        let validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -"
        let invalidCharacterSet = NSCharacterSet(charactersInString: validCharacters).invertedSet
        
        let filtered = "".join(string.componentsSeparatedByCharactersInSet(invalidCharacterSet))
        
        return string == filtered;
    }
    
// MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        var sectionCount = 0
        
        if let sections = fetchedResultsController.sections as? [NSFetchedResultsSectionInfo] {
            
            sectionCount = sections.count
        }
        
        return sectionCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        if let sections = fetchedResultsController.sections as? [NSFetchedResultsSectionInfo] {
            
            rowCount = sections[section].numberOfObjects
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if  (editingStyle == .Delete) {
            
            let treatmentCourse: TreatmentCourse = fetchedResultsController.objectAtIndexPath(indexPath) as TreatmentCourse
            
//            if (treatmentCourse.appointments.count > 0) {
//                
//                let deleteAlert = UIAlertController(title: "Delete Course", message: "\nDeleting this course will not delete any of its associated appointments but will leave them not assigned to a course.\n\nAre you sure you wish to delete this treatment course?", preferredStyle: .Alert)
//                
//                let okAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (alert: UIAlertAction!) -> Void in
//                    
//                    self.managedObjectContext.deleteObject(treatmentCourse)
//                    
//                    // Save the context
//                    var error:NSError?
//                    if (self.managedObjectContext.save(&error)) {
//                        
//                        println("Unresolved error \(error) \(error?.userInfo)")
//                        abort()
//                    }
//                })
//                deleteAlert.addAction(okAction)
//                
//                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//                deleteAlert.addAction(cancelAction)
//                
//                presentViewController(deleteAlert, animated: true, completion: nil)
//                
//            } else {
            
                managedObjectContext.deleteObject(treatmentCourse)
                
                // Save the context
                var error:NSError?
                if (!managedObjectContext.save(&error)) {
                    
                    println("Unresolved error \(error) \(error?.userInfo)")
                    abort()
                }
//            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = courseTableView.dequeueReusableCellWithIdentifier(courseCellIdentifier) as UITableViewCell
        
        configureCellAtIndexPath(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let newRow = indexPath.indexAtPosition(1)
        let oldRow = selectedCourseIndexPath?.indexAtPosition(1)
        
        if (newRow != oldRow || selectedCourseIndexPath == nil) {
            
            // Set selected course
            let treatmentCourse: TreatmentCourse = fetchedResultsController.objectAtIndexPath(indexPath) as TreatmentCourse
            selectedCourse = treatmentCourse;
            
            // Check selected course row
            let newCell = courseTableView.cellForRowAtIndexPath(indexPath)
            newCell!.accessoryType = .Checkmark
            
            if (selectedCourseIndexPath != nil) {
                
                let oldCell = courseTableView.cellForRowAtIndexPath(selectedCourseIndexPath!)
                oldCell!.accessoryType = .None;
            }
            
            // Set selected course index path
            selectedCourseIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
        }
    }

    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        let treatmentCourse: TreatmentCourse = fetchedResultsController.objectAtIndexPath(indexPath) as TreatmentCourse
        cell.textLabel!.text = treatmentCourse.courseName;
        
        cell.accessoryType = (indexPath == selectedCourseIndexPath) ? .Checkmark : .None;
    }
    
// MARK: - Fetched Results Controller
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TreatmentCourse", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "courseName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Only show courses that have not been completed
        let attendedPredicate = NSPredicate(format: "completed = %@", false)
        fetchRequest.predicate = attendedPredicate
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError?
        if !_fetchedResultsController!.performFetch(&error) {
            
            println("Unresolved error \(error) \(error?.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        courseTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch (type) {
            
        case .Insert:
            
            courseTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            
            courseTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Move:
            
            println(".Move")
            
        case .Update:
            
            println(".Update")
            
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch (type) {
            
        case .Insert:
            
            courseTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            // Uncheck last selected course row
            if (selectedCourseIndexPath != nil) {
                
                let lastSelectedCourseIndexPath = NSIndexPath(forRow: selectedCourseIndexPath!.row, inSection: selectedCourseIndexPath!.section)
                
                // Set added course row index path
                selectedCourseIndexPath = newIndexPath;
                
                configureCellAtIndexPath(courseTableView.cellForRowAtIndexPath(lastSelectedCourseIndexPath)!, indexPath: lastSelectedCourseIndexPath)
                
            } else {
                
                // Set added course row index path
                selectedCourseIndexPath = newIndexPath;
            }
            
            // Set selected course
            let treatmentCourse: TreatmentCourse = fetchedResultsController.objectAtIndexPath(newIndexPath!) as TreatmentCourse
            selectedCourse = treatmentCourse;
            
        case .Delete:
            
            if (indexPath == selectedCourseIndexPath) {
                
                selectedCourseIndexPath = nil;
                selectedCourse = nil;
            }
            courseTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)

        case .Update:
            
            configureCellAtIndexPath(courseTableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)

        case .Move:
            
            courseTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            courseTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        courseTableView.endUpdates()
    }

// MARK: - Helper Methods

    func wobbleView(viewToWobble:UIView) {
        
        var wobble: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        wobble.values = [NSValue(CATransform3D: CATransform3DMakeTranslation(-5, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeTranslation(5, 0, 0))]
        
        wobble.autoreverses = true
        wobble.repeatCount = 2
        wobble.duration = 0.10
        
        viewToWobble.layer.addAnimation(wobble, forKey: nil)
    }
}