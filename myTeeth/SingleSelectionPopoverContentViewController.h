//
//  SingleSelectionPopoverContentViewController.h
//  myTeeth
//
//  Created by David Canty on 27/05/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol SingleSelectionPopoverContentViewControllerDelegate;

@interface SingleSelectionPopoverContentViewController : UITableViewController

@property (weak, nonatomic) id <SingleSelectionPopoverContentViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (copy, nonatomic) NSString *entityName;
@property (copy, nonatomic) NSString *sortDescriptor;
@property (assign, nonatomic) BOOL isSortDescriptorAscending;
@property (strong, nonatomic) NSPredicate *predicate;
@property (copy, nonatomic) NSString *attributeForDisplay;

@property (strong, nonatomic) NSManagedObjectID *selectedObjectId;

@end

@protocol SingleSelectionPopoverContentViewControllerDelegate <NSObject>

- (void)singleSelectionPopoverContentViewControllerDidFinishWithObject:(NSManagedObject *)selectedObject;

@end