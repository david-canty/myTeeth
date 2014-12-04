//
//  TreatmentItemsViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 10/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TreatmentItem, TreatmentCategory;

@interface TreatmentItemsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) TreatmentItem *selectedTreatmentItem;

- (BOOL)shouldShowEdit;
- (void)addTreatmentItem;

- (TreatmentCategory *)getTreatmentCategoryObjectWithCategoryName:(NSString *)categoryName;

@end