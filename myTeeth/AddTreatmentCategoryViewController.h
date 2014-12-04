//
//  AddTreatmentCategoryViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 05/07/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTreatmentCategoryViewControllerDelegate;

@interface AddTreatmentCategoryViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <AddTreatmentCategoryViewControllerDelegate> delegate;
@property BOOL categoryIsBeingEdited;
@property (weak, nonatomic) NSString *editCategoryName;
@property (weak, nonatomic) IBOutlet UITextField *categoryName;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol AddTreatmentCategoryViewControllerDelegate <NSObject>

- (void)addTreatmentCategoryViewControllerDidCancel:(AddTreatmentCategoryViewController *)controller;
- (void)addTreatmentCategoryViewControllerDidFinish:(AddTreatmentCategoryViewController *)controller newCategoryName:(NSString *)newCategoryName;

@end