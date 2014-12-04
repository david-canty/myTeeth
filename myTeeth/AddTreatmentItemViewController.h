//
//  AddTreatmentItemViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 28/09/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleSelectionListViewController.h"

@protocol AddTreatmentItemViewControllerDelegate;

@interface AddTreatmentItemViewController : UITableViewController <NSFetchedResultsControllerDelegate, SingleSelectionListViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <AddTreatmentItemViewControllerDelegate> delegate;
@property BOOL itemIsBeingEdited;
@property (weak, nonatomic) NSString *editItemName;
@property (copy, nonatomic) NSString *editItemOriginalName;
@property (weak, nonatomic) IBOutlet UITextField *itemName;
@property (weak, nonatomic) NSString *editItemCategoryName;
@property (copy, nonatomic) NSString *editItemOriginalCategoryName;
@property (weak, nonatomic) IBOutlet UILabel *itemCategoryName;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) NSArray *treatmentCategoryList;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol AddTreatmentItemViewControllerDelegate <NSObject>

- (void)addTreatmentItemViewControllerDidCancel:(AddTreatmentItemViewController *)controller;
- (void)addTreatmentItemViewControllerDidFinish:(AddTreatmentItemViewController *)controller newItemName:(NSString *)newItemName newItemCategoryName:(NSString *)newItemCategoryName;

@end