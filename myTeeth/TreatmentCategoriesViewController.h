//
//  TreatmentCategoriesViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 10/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TreatmentCategory;

@interface TreatmentCategoriesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) TreatmentCategory *selectedTreatmentCategory;

- (BOOL)shouldShowEdit;
- (void)addTreatmentCategory;

@end