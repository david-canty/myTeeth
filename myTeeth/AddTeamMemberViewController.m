//
//  AddTeamMemberViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 21/04/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "AddTeamMemberViewController.h"
#import "SingleSelectionPopoverContentViewController.h"
#import "TeamMember+Utils.h"
#import "JobTitle+Utils.h"
#import "Salutation+Utils.h"

#define TITLE 0
#define JOB_TITLE 4
#define FIRST_NAME_TEXT_FIELD 2
#define MIDDLE_NAMES_TEXT_FIELD 3
#define LAST_NAME_TEXT_FIELD 4

@interface AddTeamMemberViewController () <UITextFieldDelegate, SingleSelectionPopoverContentViewControllerDelegate>

@property (strong, nonatomic) SingleSelectionPopoverContentViewController *singleSelectionPopoverVC;

@property (strong, nonatomic) JobTitle *selectedJobTitle;
@property (strong, nonatomic) Salutation *selectedSalutation;
@property (strong, nonatomic) UITextField *currentTextField;
@property (assign, nonatomic) NSUInteger nextTextFieldTag;
@property (assign, nonatomic) BOOL returnedFromPopover;

@property (strong, nonatomic) IBOutlet UILabel *teamMemberTitle;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *middleNames;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UILabel *jobTitle;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation AddTeamMemberViewController

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.editingTeamMember && !self.returnedFromPopover) {
        
        self.teamMemberTitle.text = self.editingTeamMember.teamMemberTitle;
        self.selectedSalutation = [Salutation salutationWithName:self.editingTeamMember.teamMemberTitle];
        
        self.firstName.text = self.editingTeamMember.firstName;
        self.middleNames.text = self.editingTeamMember.otherNames;
        self.lastName.text = self.editingTeamMember.lastName;
        
        self.jobTitle.text = self.editingTeamMember.jobTitle;
        self.selectedJobTitle = [JobTitle jobTitleWithName:self.editingTeamMember.jobTitle];
    }
    
    self.returnedFromPopover = NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ShowTeamMemberJobTitlePopover"]) {
        
        // Select team member job title from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"JobTitle";
        self.singleSelectionPopoverVC.sortDescriptor = @"jobTitle";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.predicate = nil;
        self.singleSelectionPopoverVC.attributeForDisplay = @"jobTitle";
        
        if (self.selectedJobTitle != nil) {
            
            self.singleSelectionPopoverVC.selectedObjectId = self.selectedJobTitle.objectID;
        }
        
        self.singleSelectionPopoverVC.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowTeamMemberSalutationPopover"]) {
        
        // Select team member salutation from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"Salutation";
        self.singleSelectionPopoverVC.sortDescriptor = @"salutation";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.predicate = nil;
        self.singleSelectionPopoverVC.attributeForDisplay = @"salutation";
        
        if (self.selectedSalutation != nil) {
            
            self.singleSelectionPopoverVC.selectedObjectId = self.selectedSalutation.objectID;
        }
        
        self.singleSelectionPopoverVC.delegate = self;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
	self.currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == FIRST_NAME_TEXT_FIELD && ![textField.text isEqualToString:@""]) {
        UILabel *label = (UILabel *)[self.view viewWithTag:11];
        label.hidden = YES;
    }
    
    if (textField.tag == LAST_NAME_TEXT_FIELD && ![textField.text isEqualToString:@""]) {
        UILabel *label = (UILabel *)[self.view viewWithTag:12];
        label.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
 
    self.nextTextFieldTag = self.currentTextField.tag;
	self.nextTextFieldTag++;
    
	if (self.nextTextFieldTag > LAST_NAME_TEXT_FIELD) {
        
		self.nextTextFieldTag = FIRST_NAME_TEXT_FIELD;
	}
	
	switch (self.nextTextFieldTag) {
		case FIRST_NAME_TEXT_FIELD:
			[self.firstName becomeFirstResponder];
			break;
		case MIDDLE_NAMES_TEXT_FIELD:
			[self.middleNames becomeFirstResponder];
			break;
		case LAST_NAME_TEXT_FIELD:
			[self.lastName becomeFirstResponder];
			break;
		default:
			break;
	}
	
	return YES;
}

- (void)singleSelectionPopoverContentViewControllerDidFinishWithObject:(NSManagedObject *)selectedObject {
    
    // Store selected object and dismiss popover
    if ([selectedObject isKindOfClass:[Salutation class]]) {
        
        self.selectedSalutation = (Salutation *)selectedObject;
        self.teamMemberTitle.text = self.selectedSalutation.salutation;
        
    } else if ([selectedObject isKindOfClass:[JobTitle class]]) {
        
        self.selectedJobTitle = (JobTitle *)selectedObject;
        self.jobTitle.text = self.selectedJobTitle.jobTitle;
    }
    
    [self.singleSelectionPopoverVC dismissViewControllerAnimated:YES completion:nil];
    self.returnedFromPopover = YES;
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

- (IBAction)done:(id)sender {
    
    BOOL validated = YES;
    
    if ([self.teamMemberTitle.text isEqualToString:NSLocalizedString(@"Please Select", @"Please Select")]) {
        [self wobbleView:self.teamMemberTitle];
        validated = NO;
    }
    
    if ([self.firstName.text isEqualToString:@""]) {
        [self wobbleView:self.firstName];
        validated = NO;
    }
    
    if ([self.lastName.text isEqualToString:@""]) {
        [self wobbleView:self.lastName];
        validated = NO;
    }
    
    if ([self.jobTitle.text isEqualToString:NSLocalizedString(@"Please Select", @"Please Select")]) {
        [self wobbleView:self.jobTitle];
        validated = NO;
    }
    
    if (validated) {
    
        TeamMember *returnedTeamMember;
        
        if (self.editingTeamMember) {
            
            // Save edited team member
            [self.editingTeamMember setTeamMemberTitle:self.teamMemberTitle.text];
            [self.editingTeamMember setFirstName:self.firstName.text];
            [self.editingTeamMember setOtherNames:self.middleNames.text];
            [self.editingTeamMember setLastName:self.lastName.text];
            [self.editingTeamMember setJobTitle:self.jobTitle.text];
            
            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            returnedTeamMember = self.editingTeamMember;
            
        } else {
            
            // Create new team member
            TeamMember *teamMember = (TeamMember *)[NSEntityDescription insertNewObjectForEntityForName:@"TeamMember" inManagedObjectContext:self.managedObjectContext];
            
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [teamMember setUniqueId:uuid];
            
            [teamMember setTeamMemberTitle:self.teamMemberTitle.text];
            [teamMember setFirstName:self.firstName.text];
            [teamMember setOtherNames:self.middleNames.text];
            [teamMember setLastName:self.lastName.text];
            [teamMember setJobTitle:self.jobTitle.text];
            
            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            returnedTeamMember = teamMember;
        }
        
        [self.delegate addTeamMemberViewControllerDidFinishWithTeamMember:returnedTeamMember];
    }
}

- (void)wobbleView:(UIView *)viewToWobble {
    
    CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
    wobble.autoreverses = YES;
    wobble.repeatCount = 2.0f;
    wobble.duration = 0.10f;
    [viewToWobble.layer addAnimation:wobble forKey:nil];
}

@end