//
//  DetailViewController.h
//  myTeeth
//
//  Created by Dave on 08/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface DetailViewController : UIViewController

//@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) Patient *patient;
@property (copy, nonatomic) NSManagedObjectID *selectedPatientObjectId;
@property (copy, nonatomic) NSString *selectedPatientUniqueId;

- (void)loadSelectedPatient;
- (void)deselectPatient;
- (void)enablePatientButton;
- (void)disablePatientButton;
- (void)refreshView;

@end