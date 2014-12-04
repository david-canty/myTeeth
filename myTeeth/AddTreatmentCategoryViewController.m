//
//  AddTreatmentCategoryViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 05/07/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "AddTreatmentCategoryViewController.h"
#import "TreatmentCategory.h"

@implementation AddTreatmentCategoryViewController

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
    [self setCategoryName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.categoryIsBeingEdited) {
        self.categoryName.text = self.editCategoryName;
        [self.categoryName becomeFirstResponder];
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

- (IBAction)cancel:(id)sender {
     [[self delegate] addTreatmentCategoryViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    
    if (self.categoryIsBeingEdited && [self.categoryName.text isEqualToString:self.editCategoryName]) {
        [[self delegate] addTreatmentCategoryViewControllerDidCancel:self];
    } else {
        BOOL validated = YES;
        if ([self.categoryName.text isEqualToString:@""]) {
            UILabel *label = (UILabel *)[self.view viewWithTag:10];
            label.hidden = NO;
            UILabel *validationMessage = (UILabel *)[self.view viewWithTag:11];
            validationMessage.text = NSLocalizedString(@"* please complete the required fields", @"* please complete the required fields");
            validationMessage.hidden = NO;
            validated = NO;
        } else {
            UILabel *label = (UILabel *)[self.view viewWithTag:10];
            label.hidden = YES;
            UILabel *validationMessage = (UILabel *)[self.view viewWithTag:11];
            validationMessage.hidden = YES;
        }
        if (validated) {
            
            // check for duplicate treatment category
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
            [request setEntity:category];
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"categoryName == %@", self.categoryName.text];
            [request setPredicate:predicate];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
            NSArray *sortDescriptors = @[sortDescriptor];
            [request setSortDescriptors:sortDescriptors];
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
            aFetchedResultsController.delegate = self;
            NSError *error = nil;
            NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
            if ((result != nil) && ([result count] == 0) && (error == nil)) {
                [[self delegate] addTreatmentCategoryViewControllerDidFinish:self newCategoryName:self.categoryName.text];
            } else {
                UILabel *label = (UILabel *)[self.view viewWithTag:10];
                label.hidden = NO;
                UILabel *validationMessage = (UILabel *)[self.view viewWithTag:11];
                validationMessage.text = NSLocalizedString(@"* a treatment category with this name already exists", @"* a treatment category with this name already exists");
                validationMessage.hidden = NO;
            }
            
        }
        
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UILabel *label = (UILabel *)[self.view viewWithTag:10];
    label.hidden = YES;
    UILabel *validationMessage = (UILabel *)[self.view viewWithTag:11];
    validationMessage.hidden = YES;
    return YES;
}

@end
