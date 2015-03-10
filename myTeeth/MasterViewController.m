//
//  MasterViewController.m
//  myTeeth
//
//  Created by Dave on 08/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "TeamMemberViewController.h"
#import "PatientViewController.h"
#import "AddAppointmentViewController.h"
#import "AppointmentViewController.h"
#import "AppointmentHistoryViewController.h"
#import "TreatmentCategoriesItemsViewController.h"
#import "NotesViewController.h"
#import "ChargeTypeManagement_iPad.h"
#import "DentalPractice+Utils.h"
#import "BillsViewController.h"

@interface MasterViewController () <AddAppointmentViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate>

@property (strong, nonatomic) UIAlertController *registeredDentailPracticeAlertController;

@property (copy, nonatomic) NSNumber *registeredPracticeContactId;
@property (copy, nonatomic) NSString *registeredPracticeName;
@property (strong, nonatomic) EKEventStore *eventStore;

@property (weak, nonatomic) IBOutlet UITableViewCell *registeredDentalPracticeCell;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.detailViewController.managedObjectContext = self.managedObjectContext;
    self.detailViewController.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationController.toolbarHidden = NO;
    self.receptionNavigationItem.title = NSLocalizedString(@"Reception", @"Reception");
    
    // Create empty Dental Practice entity
    if (![self isDentalPracticeCreated]) {
        
        DentalPractice *dentalPractice = (DentalPractice *)[NSEntityDescription insertNewObjectForEntityForName:@"DentalPractice" inManagedObjectContext:self.managedObjectContext];
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [dentalPractice setUniqueId:uuid];
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Get reference to Event Store
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.eventStore = appDelegate.eventStore;
}

- (BOOL)isDentalPracticeCreated {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DentalPractice" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *err;
    NSUInteger fetchCountForDentalPractice = [self.managedObjectContext countForFetchRequest:request error:&err];
    
    if (fetchCountForDentalPractice == 0) {
        
        return NO;
    }
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Disable registered dental practice row if none selected
    NSString *registeredPracticeContactId = [DentalPractice dentalPracticeContactId];
    ABRecordRef contactPerson = nil;
    ABAddressBookRef addressBook = nil;
    if (registeredPracticeContactId != nil) {
        
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordID practiceContactId = (ABRecordID)[registeredPracticeContactId intValue];
        contactPerson = ABAddressBookGetPersonWithRecordID(addressBook, practiceContactId);
        
    }
    
    if (!contactPerson) {
    
        self.registeredDentalPracticeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.registeredDentalPracticeCell.textLabel.textColor = [UIColor lightGrayColor];
        
    } else {
        
        self.registeredDentalPracticeCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.registeredDentalPracticeCell.textLabel.textColor = [UIColor blackColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self.registeredDentailPracticeAlertController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Table View

// table sections
#define MY_DENTIST      0
#define MY_APPOINTMENTS 1
#define MY_TREATMENT    2
#define MY_DENTAL_BILLS 3
#define MY_DENTAL_NOTES 4

// table section rows
#define REGISTERED_DENTAL_PRACTICE  0
#define DENTAL_TEAM_MEMBERS         1
#define PATIENT_DETAILS             2
#define ADD_APPOINTMENT             0
#define SCHEDULED_APPOINTMENTS      1
#define APPOINTMENT_HISTORY         0
#define TREATMENT_CATEGORIES_ITEMS  1
#define BILLS                       0
#define NOTES                       0

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
    switch (section) {
        case MY_DENTIST: {
            
            switch (row) {
                    
                case REGISTERED_DENTAL_PRACTICE: {
                    
                    // First check we haven't already linked to a contact and then deleted the contact
                    NSString *registeredPracticeContactId = [DentalPractice dentalPracticeContactId];
                    ABRecordRef contactPerson = nil;
                    ABAddressBookRef addressBook = nil;
                    if (registeredPracticeContactId != nil) {
                        
                        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                        ABRecordID practiceContactId = (ABRecordID)[registeredPracticeContactId intValue];
                        contactPerson = ABAddressBookGetPersonWithRecordID(addressBook, practiceContactId);
                        
                    }
                    
                    // If there is a dental practice already registered, display it
                    if (contactPerson != nil) {
                        
                        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
                        picker.personViewDelegate = self;
                        
                        NSArray *displayedItems = [NSArray arrayWithObjects:
                                                   [NSNumber numberWithInt:kABPersonFirstNameProperty],
                                                   [NSNumber numberWithInt:kABPersonLastNameProperty],
                                                   [NSNumber numberWithInt:kABPersonOrganizationProperty],
                                                   [NSNumber numberWithInt:kABPersonPhoneProperty],
                                                   [NSNumber numberWithInt:kABPersonAddressProperty],
                                                   [NSNumber numberWithInt:kABPersonEmailProperty],
                                                   [NSNumber numberWithInt:kABPersonURLProperty], nil];
                        
                        picker.displayedProperties = displayedItems;
                        picker.displayedPerson = contactPerson;
                        
                        picker.allowsEditing = YES;
                        [self.navigationController pushViewController:picker animated:YES];
                        CFRelease(addressBook);
                        
                    }
                    
                    break;
                }
            }
            break;
        }
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"ShowRemindersView"]) {
    
        // Check if user has granted access to calendar
        EKAuthorizationStatus eventStoreAccessStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if (eventStoreAccessStatus == EKAuthorizationStatusDenied ||
            eventStoreAccessStatus == EKAuthorizationStatusNotDetermined) {
            
            // Access to calendar not granted so refer user to Settings
            UIAlertController *addressBookAlert = [UIAlertController alertControllerWithTitle:@"This app does not have access to your calendar."
                                                                                      message:@"You can enable access in Privacy Settings."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:nil];
            [addressBookAlert addAction:okAction];
            
            [self presentViewController:addressBookAlert animated:YES completion:nil];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowTeamMemberView"]) {
        TeamMemberViewController *controller = (TeamMemberViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.detailViewController = self.detailViewController;
    }
    if ([[segue identifier] isEqualToString:@"ShowPatientView"]) {
        PatientViewController *controller = (PatientViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        controller.detailViewController = self.detailViewController;
    }
    if ([[segue identifier] isEqualToString:@"ShowAddAppointmentView"]) {
        AddAppointmentViewController *controller = (AddAppointmentViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.navigationItem.title = NSLocalizedString(@"Add Appointment", @"Add Appointment");
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"ShowAppointmentView"]) {
        AppointmentViewController *controller = (AppointmentViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Appointments", @"Appointments");
        controller.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowAppointmentHistoryView"]) {
        AppointmentHistoryViewController *controller = (AppointmentHistoryViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Appointment History", @"Appointment History");
        controller.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowTreatmentCategoriesItemsView"]) {
        TreatmentCategoriesItemsViewController *controller = (TreatmentCategoriesItemsViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowBillsView"]) {
        BillsViewController *controller = (BillsViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Bills", @"Bills");
        controller.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowChargeTypeManagement"]) {
        ChargeTypeManagement_iPad *chargeVC = (ChargeTypeManagement_iPad *)[segue destinationViewController];
        chargeVC.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowNotesView"]) {
        NotesViewController *notesVC = (NotesViewController *)[segue destinationViewController];
        notesVC.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue identifier] isEqualToString:@"ShowSettingsView"]) {
        
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == REGISTERED_DENTAL_PRACTICE) {
    
        // Register a dental practice
        self.registeredDentailPracticeAlertController = [UIAlertController alertControllerWithTitle:@"Your Registered Dental Practice is linked to an entry in your Contacts."
                                                                                            message:@"You can add a new contact or select an existing contact."
                                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Position alert popover
        UITableViewCell *tappedCell = [tableView cellForRowAtIndexPath:indexPath];
        self.registeredDentailPracticeAlertController.popoverPresentationController.sourceView = tappedCell;
        CGRect popoverRect = CGRectMake(tappedCell.frame.size.width / 2,
                                        0,
                                        0,
                                        tappedCell.frame.size.height);
        self.registeredDentailPracticeAlertController.popoverPresentationController.sourceRect = popoverRect;
        self.registeredDentailPracticeAlertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        
        UIAlertAction *addNewContactAction = [UIAlertAction actionWithTitle:@"Add New Contact" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                        ABNewPersonViewController *personViewController = [[ABNewPersonViewController alloc] init];
                                                                                                                                                    personViewController.edgesForExtendedLayout = UIRectEdgeNone;
                                                                        
                                                                        personViewController.newPersonViewDelegate = self;
                                                                        
                                                                        UINavigationController *newNavigationController = [[UINavigationController alloc] initWithRootViewController:personViewController];
                                                                        
                                                                        [self.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
                                                                        
                                                                        [self presentViewController:newNavigationController animated:YES completion:^{
                                                                            
                                                                            
                                                                        }];
                                                                    }];
        [self.registeredDentailPracticeAlertController addAction:addNewContactAction];
        
        UIAlertAction *selectExistingContactAction = [UIAlertAction actionWithTitle:@"Select Existing Contact" style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                        
                                                                                [self requestAccessToAddressBook];
                                                                                                                                                                }];
        [self.registeredDentailPracticeAlertController addAction:selectExistingContactAction];
        
        [self presentViewController:self.registeredDentailPracticeAlertController animated:YES completion:nil];
    }
}

- (void)requestAccessToAddressBook {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            
            if (granted) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
                    
                    picker.peoplePickerDelegate = self;
                    
                    [self.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
                    
                    [self presentViewController:picker animated:YES completion:^{
                        
                        
                    }];
                });
            }
        });
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        
        picker.peoplePickerDelegate = self;
        
        [self.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
        
        [self presentViewController:picker animated:YES completion:^{
            
            
        }];
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        
        // Display alert referring user to Privacy Settings
        UIAlertController *addressBookAlert = [UIAlertController alertControllerWithTitle:@"This app does not have access to your contacts."
                                                                                            message:@"You can enable access in Privacy Settings."
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                            handler:nil];
        [addressBookAlert addAction:okAction];
        
        [self presentViewController:addressBookAlert animated:YES completion:nil];
    }
}

#pragma mark - New person delegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    
    if (person != nil) {
        
        // Save contact record id and name
        self.registeredPracticeContactId = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
        self.registeredPracticeName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        
        [DentalPractice setDentalPracticeContactId:[NSString stringWithFormat:@"%@", self.registeredPracticeContactId]];
        [DentalPractice setDentalPracticeName:self.registeredPracticeName];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        self.registeredDentalPracticeCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.registeredDentalPracticeCell.textLabel.textColor = [UIColor blackColor];
    }];
}

#pragma mark - People picker delegate
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self savePickedPerson:person];
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    [self savePickedPerson:person];
}

- (void)savePickedPerson:(ABRecordRef)person {
    
    // Save contact record id and name
    self.registeredPracticeContactId = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
    self.registeredPracticeName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    
    [DentalPractice setDentalPracticeContactId:[NSString stringWithFormat:@"%@", self.registeredPracticeContactId]];
    [DentalPractice setDentalPracticeName:self.registeredPracticeName];
    
    self.registeredDentalPracticeCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.registeredDentalPracticeCell.textLabel.textColor = [UIColor blackColor];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
    
    return YES;
}

#pragma mark - Add appointment delegate
- (void)addAppointmentViewControllerDidCancel:(AddAppointmentViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)addAppointmentViewControllerDidFinish:(AddAppointmentViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end