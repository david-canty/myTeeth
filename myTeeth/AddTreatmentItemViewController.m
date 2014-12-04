//
//  AddTreatmentItemViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 28/09/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "AddTreatmentItemViewController.h"
#import "TreatmentCategory.h"

@implementation AddTreatmentItemViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setItemName:nil];
    [self setItemCategoryName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.itemIsBeingEdited) {
        self.itemName.text = self.editItemName;
        self.itemCategoryName.text = self.editItemCategoryName;
        [self.itemName becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowSelectTreatmentCategoryView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Treatment Category", @"Treatment Category");
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        NSError *error = nil;
        NSArray *treatementCategoryEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *categories = [@[] mutableCopy];
        
        for (TreatmentCategory *treatementCategoryEntity in treatementCategoryEntities) {
            
            [categories addObject:@{@"displayName" : treatementCategoryEntity.categoryName,
                                    @"uniqueId" : treatementCategoryEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName"  ascending:YES];
        self.treatmentCategoryList = [categories sortedArrayUsingDescriptors:@[descriptor]];
        selectionListViewController.selectionList = self.treatmentCategoryList;
        
        NSUInteger initialSelectionIndex = 0;
        initialSelectionIndex = [self.treatmentCategoryList indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                
                                return [[dict objectForKey:@"displayName"] isEqual:self.itemCategoryName.text];
                            }
                            ];
        selectionListViewController.initialSelection = initialSelectionIndex;
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a category for this treatment item", @"Please select a category for this treatment item");
    }
}

- (void)singleSelectionListViewControllerDidFinish:(SingleSelectionListViewController *)controller withSelectedItem:(NSDictionary *)selectedItem {
    if (self.itemIsBeingEdited) {
        self.editItemCategoryName = selectedItem[@"displayName"];
    } else {
        self.itemCategoryName.text = selectedItem[@"displayName"];
    }
}

- (IBAction)cancel:(id)sender {
    [[self delegate] addTreatmentItemViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    
    if (self.itemIsBeingEdited && [self.itemName.text isEqualToString:self.editItemOriginalName] && [self.itemCategoryName.text isEqualToString:self.editItemOriginalCategoryName]) {
        [[self delegate] addTreatmentItemViewControllerDidCancel:self];
    } else {
        BOOL validated = YES;
        
        if ([self.itemName.text isEqualToString:@""]) {
            UILabel *label = (UILabel *)[self.view viewWithTag:10];
            label.hidden = NO;
            UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
            validationMessage.hidden = NO;
            validated = NO;
        } else {
            UILabel *label = (UILabel *)[self.view viewWithTag:10];
            label.hidden = YES;
            UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
            validationMessage.hidden = YES;
        }
        
        if ([self.itemCategoryName.text isEqualToString:@"Please Select"]) {
            UILabel *label = (UILabel *)[self.view viewWithTag:11];
            label.hidden = NO;
            UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
            validationMessage.hidden = NO;
            validated = NO;
        } else {
            UILabel *label = (UILabel *)[self.view viewWithTag:11];
            label.hidden = YES;
            if (validated) {
                // only hide validation message if item name was validated
                UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
                validationMessage.hidden = YES;
            }
        }
        
        if (validated) {
            
            // check for duplicate treatment item
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentItem" inManagedObjectContext:self.managedObjectContext];
            [request setEntity:category];
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"itemName == %@", self.itemName.text];
            [request setPredicate:predicate];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemName" ascending:YES];
            NSArray *sortDescriptors = @[sortDescriptor];
            [request setSortDescriptors:sortDescriptors];
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            aFetchedResultsController.delegate = self;
            NSError *error = nil;
            NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
            if (((result != nil) && ([result count] == 0) && (error == nil))) {
                [[self delegate] addTreatmentItemViewControllerDidFinish:self newItemName:self.itemName.text newItemCategoryName:self.itemCategoryName.text];
            } else {
                UILabel *label = (UILabel *)[self.view viewWithTag:10];
                label.hidden = NO;
                UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
                validationMessage.text = NSLocalizedString(@"* a treatment item with this name already exists", @"* a treatment item with this name already exists");
                validationMessage.hidden = NO;
            }

        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UILabel *label1 = (UILabel *)[self.view viewWithTag:10];
    label1.hidden = YES;
    UILabel *label2 = (UILabel *)[self.view viewWithTag:11];
    label2.hidden = YES;
    UILabel *validationMessage = (UILabel *)[self.view viewWithTag:12];
    validationMessage.hidden = YES;
    return YES;
}

@end
