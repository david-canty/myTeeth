//
//  AddPatientViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 10/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "AddPatientViewController.h"
#import "SingleSelectionPopoverContentViewController.h"
#import "SingleSelectionListViewController.h"
#import "DateOfBirthViewController.h"
#import "Patient+Utils.h"
#import "TeamMember+Utils.h"
#import "Salutation+Utils.h"
#import "Tooth+Utils.h"
#import "AppDelegate.h"
#import "DentalPractice+Utils.h"
#import "Appointment+Utils.h"
#import "Note+Utils.h"

// Text field tags
#define FIRST_NAME_TEXT_FIELD 2
#define MIDDLE_NAMES_TEXT_FIELD 3
#define LAST_NAME_TEXT_FIELD 4

@interface AddPatientViewController () <UITextFieldDelegate, SingleSelectionPopoverContentViewControllerDelegate, SingleSelectionListViewControllerDelegate, DateOfBirthViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) SingleSelectionPopoverContentViewController *singleSelectionPopoverVC;
@property (strong, nonatomic) UIPopoverController *singleSelectionPopoverController;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) Salutation *selectedSalutation;
@property (strong, nonatomic) NSDate *selectedDateOfBirth;
@property (assign, nonatomic) NSUInteger selectedCalendarIndex;
@property (strong, nonatomic) NSString *selectedCalendarId;
@property (strong, nonatomic) NSString *selectedCalendarTitle;
@property (assign, nonatomic) NSUInteger selectedAppointmentAlertIndex;
@property (strong, nonatomic) NSNumber *selectedAppointmentAlertValue;
@property (assign, nonatomic) NSUInteger selectedCheckupAlertIndex;
@property (strong, nonatomic) NSNumber *selectedCheckupAlertValue;
@property (assign, nonatomic) NSUInteger selectedCheckupIntervalIndex;
@property (strong, nonatomic) NSNumber *selectedCheckupIntervalValue;
@property (copy, nonatomic) NSString *selectionListMode;

@property (strong, nonatomic) UITextField *currentTextField;
@property (assign, nonatomic) NSUInteger nextTextFieldTag;
@property (assign, nonatomic) BOOL returnedFromPopoverOrView;

@property (strong, nonatomic) NSArray *eventAlertValues;
@property (strong, nonatomic) NSArray *checkupIntervalValues;
@property (strong, nonatomic) NSArray *calendars;

@property (assign, nonatomic) BOOL isTopViewController;

@property (weak, nonatomic) IBOutlet UILabel *patientTitle;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *middleNames;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UILabel *patientDateOfBirth;

@property (weak, nonatomic) IBOutlet UISwitch *appointmentReminderSwitch;
@property (weak, nonatomic) IBOutlet UILabel *appointmentReminderCalendarLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentAlertLabel;
@property (weak, nonatomic) IBOutlet UISwitch *checkupReminderSwitch;
@property (weak, nonatomic) IBOutlet UILabel *checkupIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkupAlertLabel;

- (IBAction)appointmentReminderSwitchTapped:(id)sender;
- (IBAction)checkupReminderSwitchTapped:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation AddPatientViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    self.isTopViewController = YES;
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self createEventAlertValues];
    [self createCheckupIntervalValues];
    [self getCalendars];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.editingPatient && !self.returnedFromPopoverOrView) {
        
        self.patientTitle.text = self.editingPatient.patientTitle;
        self.selectedSalutation = [Salutation salutationWithName:self.editingPatient.patientTitle];

        self.firstName.text = self.editingPatient.firstName;
        self.middleNames.text = self.editingPatient.otherNames;
        self.lastName.text = self.editingPatient.lastName;
        
        self.selectedDateOfBirth = self.editingPatient.dateOfBirth;
        [self populateDateOfBirthLabel];
        
        if ([[self.editingPatient addAppointmentEvents] boolValue]) {
            
            [self.appointmentReminderSwitch setOn:YES];
            self.appointmentReminderCalendarLabel.enabled = YES;
            self.appointmentAlertLabel.enabled = YES;
            
        } else {
            
            [self.appointmentReminderSwitch setOn:NO];
            self.appointmentReminderCalendarLabel.enabled = NO;
            self.appointmentAlertLabel.enabled = NO;
        }
        
        if ([[self.editingPatient addCheckupEvents] boolValue]) {
            
            [self.checkupReminderSwitch setOn:YES];
            self.checkupIntervalLabel.enabled = YES;
            self.checkupAlertLabel.enabled = YES;
            
        } else {
            
            [self.checkupReminderSwitch setOn:NO];
            self.checkupIntervalLabel.enabled = NO;
            self.checkupAlertLabel.enabled = NO;
        }
        
        if ([self.appDelegate.eventStore calendarWithIdentifier:self.editingPatient.calendarId] == nil) {
            
            // If calendar no longer exists, update patient's calendar id and title with defaultCalendarForNewEvents' identifier and title
            EKCalendar *defaultCalendar = [self.appDelegate.eventStore defaultCalendarForNewEvents];
            self.editingPatient.calendarId = defaultCalendar.calendarIdentifier;
            self.editingPatient.calendarTitle = defaultCalendar.title;
        }
        
        self.selectedCalendarIndex = [self calendarIndexForTitle:self.editingPatient.calendarTitle];
        self.selectedCalendarId = self.editingPatient.calendarId;
        self.selectedCalendarTitle = self.editingPatient.calendarTitle;
        [self populateSelectedCalendar];
        
        self.selectedAppointmentAlertIndex = [self alertIndexForValue:self.editingPatient.appointmentAlert];
        self.selectedAppointmentAlertValue = self.editingPatient.appointmentAlert;
        [self populateSelectedAppointmentAlert];
        
        self.selectedCheckupAlertIndex = [self alertIndexForValue:self.editingPatient.checkupAlert];
        self.selectedCheckupAlertValue = self.editingPatient.checkupAlert;
        [self populateSelectedCheckupAlert];
        
        self.selectedCheckupIntervalIndex = [self checkupIntervalIndexForValue:self.editingPatient.checkupInterval];
        self.selectedCheckupIntervalValue = self.editingPatient.checkupInterval;
        [self populateSelectedCheckupInterval];
        
    } else if (!self.returnedFromPopoverOrView  &&
               self.isTopViewController) {
        
        [self.appointmentReminderSwitch setOn:NO];
        self.appointmentReminderCalendarLabel.enabled = NO;
        self.appointmentAlertLabel.enabled = NO;
        
        // Default calendar to 'Calendar'
        self.selectedCalendarIndex = [self calendarIndexForTitle:@"Calendar"];
        self.selectedCalendarId = [self calendarIdentiferForTitle:@"Calendar"];
        self.selectedCalendarTitle = @"Calendar";
        [self populateSelectedCalendar];
        
        self.selectedAppointmentAlertIndex = 0;
        self.selectedAppointmentAlertValue = @-1;
        [self populateSelectedAppointmentAlert];
        
        [self.checkupReminderSwitch setOn:NO];
        self.checkupIntervalLabel.enabled = NO;
        self.checkupAlertLabel.enabled = NO;
        
        self.selectedCheckupAlertIndex = 0;
        self.selectedCheckupAlertValue = @-1;
        [self populateSelectedCheckupAlert];
        
        self.selectedCheckupIntervalIndex = 0;
        self.selectedCheckupIntervalValue = @0;
        [self populateSelectedCheckupInterval];
    }
    
    self.returnedFromPopoverOrView = NO;
    self.isTopViewController = YES;
    self.selectionListMode = @"";
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    self.isTopViewController = YES;
    
    // If we're returning from a navigation controller via back button, we don't want to initialize view again
    if (self.navigationController.topViewController != self) {
        
        self.isTopViewController = NO;
    }
}

- (void)populateSelectedCalendar {
    
    NSDictionary *calendarDict = self.calendars[self.selectedCalendarIndex];
    
    // Add a respectively colored • to beginning of selected calendar
    NSDictionary *modifedLabelAttributes = @{
                                             NSForegroundColorAttributeName : calendarDict[@"itemColor"],
                                             NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:36.0]};
    NSDictionary *labelBaselibeAttribute = @{
                                             NSBaselineOffsetAttributeName : @8.0};
    NSString *itemString = [NSString stringWithFormat:@"• %@", calendarDict[@"displayName"]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:itemString];
    [attributedString setAttributes:modifedLabelAttributes range:NSMakeRange(0, 1)];
    [attributedString setAttributes:labelBaselibeAttribute range:NSMakeRange(1, attributedString.length-1)];
    
    self.appointmentReminderCalendarLabel.attributedText = attributedString;
}

- (void)populateSelectedAppointmentAlert {
    
    self.appointmentAlertLabel.text = self.eventAlertValues[self.selectedAppointmentAlertIndex][@"displayName"];
}

- (void)populateSelectedCheckupAlert {
    
    self.checkupAlertLabel.text = self.eventAlertValues[self.selectedCheckupAlertIndex][@"displayName"];
}

- (void)populateSelectedCheckupInterval {
    
    self.checkupIntervalLabel.text = self.checkupIntervalValues[self.selectedCheckupIntervalIndex][@"displayName"];
}

- (void)createEventAlertValues {
    
    self.eventAlertValues = @[@{@"displayName" : @"None",
                                @"uniqueId" : @-1},
                              @{@"displayName" : @"At time of event",
                                @"uniqueId" : @0},
                              @{@"displayName" : @"5 minutes before",
                                @"uniqueId" : @300},
                              @{@"displayName" : @"10 minutes before",
                                @"uniqueId" : @600},
                              @{@"displayName" : @"15 minutes before",
                                @"uniqueId" : @900},
                              @{@"displayName" : @"30 minutes before",
                                @"uniqueId" : @1800},
                              @{@"displayName" : @"1 hour before",
                                @"uniqueId" : @3600},
                              @{@"displayName" : @"2 hours before",
                                @"uniqueId" : @7200},
                              @{@"displayName" : @"1 day before",
                                @"uniqueId" : @86400},
                              @{@"displayName" : @"2 days before",
                                @"uniqueId" : @172800}];
}

- (NSUInteger)alertIndexForValue:(NSNumber *)alertValue {
    
    NSUInteger alertIndex = 0;
    
    switch ([alertValue integerValue]) {
        case -1:
            return 0;
            break;
        case 0:
            return 1;
            break;
        case 300:
            return 2;
            break;
        case 600:
            return 3;
            break;
        case 900:
            return 4;
            break;
        case 1800:
            return 5;
            break;
        case 3600:
            return 6;
            break;
        case 7200:
            return 7;
            break;
        case 86400:
            return 8;
            break;
        case 172800:
            return 9;
            break;
        default:
            break;
    }
    
    return alertIndex;
}

- (void)createCheckupIntervalValues {
    
    self.checkupIntervalValues =  @[@{@"displayName" : @"None", @"uniqueId" : @0},
  @{@"displayName" : @"3 months after last appointment", @"uniqueId" : @7884000},
  @{@"displayName" : @"6 months after last appointment", @"uniqueId" : @15768000},
  @{@"displayName" : @"9 months after last appointment", @"uniqueId" : @23652000},
  @{@"displayName" : @"1 year after last appointment", @"uniqueId" : @31536000},
  @{@"displayName" : @"18 months after last appointment", @"uniqueId" : @47304000},
  @{@"displayName" : @"2 years after last appointment", @"uniqueId" : @63072000}];
}

- (NSUInteger)checkupIntervalIndexForValue:(NSNumber *)alertValue {
 
    NSUInteger checkupIntervalIndex = 0;
    
    switch ([alertValue integerValue]) {
        case 0:
            return 0;
            break;
        case 7884000:
            return 1;
            break;
        case 15768000:
            return 2;
            break;
        case 23652000:
            return 3;
            break;
        case 31536000:
            return 4;
            break;
        case 47304000:
            return 5;
            break;
        case 63072000:
            return 6;
            break;
        default:
            break;
    }
    
    return checkupIntervalIndex;
}

- (void)getCalendars {
    
    NSArray *allCalendars = [self.appDelegate.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *calendars = [@[] mutableCopy];
    
    for (EKCalendar *calendar in allCalendars) {
        
        if (![calendar.title isEqualToString:@"Birthdays"]) { // Exclude Birthdays calendar

            [calendars addObject:@{@"displayName" : calendar.title,
                                   @"uniqueId" : calendar.calendarIdentifier,
                                   @"itemColor": [UIColor colorWithCGColor:calendar.CGColor]
                                   }];
        }
    }
    
    self.calendars = calendars;
}

- (NSUInteger)calendarIndexForTitle:(NSString *)calendarTitle {
 
    NSUInteger calendarIndex = 0;
    
    for (NSDictionary *calendarDict in self.calendars) {
        
        if ([calendarDict[@"displayName"] isEqualToString:calendarTitle]) {
            
            calendarIndex = [self.calendars indexOfObject:calendarDict];
        }
    }
    
    return calendarIndex;
}

- (NSString *)calendarIdentiferForTitle:(NSString *)calendarTitle {
    
    NSString *calendarIdentifier = @"";
    
    for (NSDictionary *calendarDict in self.calendars) {
        
        if ([calendarDict[@"displayName"] isEqualToString:calendarTitle]) {
            
            calendarIdentifier = calendarDict[@"uniqueId"];
        }
    }
    
    return calendarIdentifier;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"ShowCalendarSelectionView"]) {
        
        if (!self.appointmentReminderSwitch.isOn) {
            
            return NO;
        }
        
    } else if ([identifier isEqualToString:@"ShowAppointmentAlertView"]) {
        
        if (!self.appointmentReminderSwitch.isOn) {
            
            return NO;
        }
        
    } else if ([identifier isEqualToString:@"ShowCheckupAlertView"]) {
        
        if (!self.checkupReminderSwitch.isOn) {
            
            return NO;
        }
        
    } else if ([identifier isEqualToString:@"ShowCheckupIntervalView"]) {
        
        if (!self.checkupReminderSwitch.isOn) {
            
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowPatientSalutationPopover"]) {
        
        // Select patient salutation from popover
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
        
        // Store reference to popover for dismissal after item is selected
        self.singleSelectionPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        
    } else if ([[segue identifier] isEqualToString:@"ShowDateOfBirthView"]) {
        
        DateOfBirthViewController *dateOfBirthController = [segue destinationViewController];
        dateOfBirthController.navigationItem.title = NSLocalizedString(@"Date of Birth", @"Date of Birth");
        dateOfBirthController.delegate = self;
        
        // Pre-select date if already selected
        if (self.selectedDateOfBirth) {
            
            dateOfBirthController.datePickerDate = self.selectedDateOfBirth;
            
        } else {
            
            dateOfBirthController.datePickerDate = [NSDate date];
        }
        
    } else if ([[segue identifier] isEqualToString:@"ShowCalendarSelectionView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Appointment Calendar", @"Appointment Calendar");
        
        selectionListViewController.selectionList = self.calendars;
        
        // Pre-select calendar
        selectionListViewController.initialSelection = self.selectedCalendarIndex;
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Select a calendar for appointments and checkup reminder events", @"Select a calendar for appointments and checkup reminder events");
        
        self.selectionListMode = @"Calendar";
        
    } else if ([[segue identifier] isEqualToString:@"ShowAppointmentAlertView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Appointment Alert", @"Appointment Alert");
        
        selectionListViewController.selectionList = self.eventAlertValues;
        
        // Pre-select alert
        selectionListViewController.initialSelection = self.selectedAppointmentAlertIndex;
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Select an alert for appointment calendar events", @"Select an alert for appointment calendar events");
        
        self.selectionListMode = @"AppointmentAlert";
        
    } else if ([[segue identifier] isEqualToString:@"ShowCheckupIntervalView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Checkup Reminder Interval", @"Regular Checkup Interval");
        
        selectionListViewController.selectionList = self.checkupIntervalValues;
        
        // Pre-select interval
        selectionListViewController.initialSelection = self.selectedCheckupIntervalIndex;
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Select an interval for checkup reminder calendar events", @"Select an interval for checkup reminder calendar events");
        selectionListViewController.sectionFooter = NSLocalizedString(@"A checkup reminder calendar event is a recurring event based on the selected reminder interval.\n\nIf there are no previous appointments, today's date will be used as the start of the checkup reminder interval instead of the date of the last appopintment.", @"A checkup reminder calendar event is a recurring event based on the selected reminder interval.\n\nIf there are no previous appointments, today's date will be used as the start of the checkup reminder interval instead of the date of the last appopintment.");
        
        self.selectionListMode = @"CheckupInterval";
        
    } else if ([[segue identifier] isEqualToString:@"ShowCheckupAlertView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Checkup Reminder Alert", @"Regular Checkup Alert");
        
        selectionListViewController.selectionList = self.eventAlertValues;
        
        // Pre-select alert
        selectionListViewController.initialSelection = self.selectedCheckupAlertIndex;
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Select an alert for checkup reminder calendar events", @"Select an alert for checkup reminder calendar events");
        
        self.selectionListMode = @"CheckupAlert";
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
	self.currentTextField = textField;
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
        self.patientTitle.text = self.selectedSalutation.salutation;
    }
    
    [self.singleSelectionPopoverController dismissPopoverAnimated:YES];
    self.returnedFromPopoverOrView = YES;
}

- (void)dateOfBirthViewControllerDidFinish:(DateOfBirthViewController *)controller WithDate:(NSDate *)date {

    self.selectedDateOfBirth = date;
    [self populateDateOfBirthLabel];
    [self.navigationController popViewControllerAnimated:YES];
    self.returnedFromPopoverOrView = YES;
}

- (void)populateDateOfBirthLabel {
    
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [outputDateFormatter setDateFormat:@"d MMMM yyyy"];
    NSString *dateTimeString = [outputDateFormatter stringFromDate:self.selectedDateOfBirth];
    self.patientDateOfBirth.text = dateTimeString;
}

#pragma mark - Calendar events
- (IBAction)appointmentReminderSwitchTapped:(id)sender {
    
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
        
        [self presentViewController:addressBookAlert animated:YES completion:^{
            
            // Turn switch back off
            [self.appointmentReminderSwitch setOn:NO animated:YES];
        }];
        
    } else {
        
        if ([self.appointmentReminderSwitch isOn]) {
            
            self.appointmentReminderCalendarLabel.enabled = YES;
            self.appointmentAlertLabel.enabled = YES;
            
        } else {
            
            self.appointmentReminderCalendarLabel.enabled = NO;
            self.appointmentAlertLabel.enabled = NO;
        }
    }
}

- (IBAction)checkupReminderSwitchTapped:(id)sender {
    
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
        
        [self presentViewController:addressBookAlert animated:YES completion:^{
         
            // Turn switch back off
            [self.checkupReminderSwitch setOn:NO animated:YES];
        }];
        
    } else {
        
        if ([self.checkupReminderSwitch isOn]) {
            
            self.checkupIntervalLabel.enabled = YES;
            self.checkupAlertLabel.enabled = YES;
            
        } else {
            
            self.checkupIntervalLabel.enabled = NO;
            self.checkupAlertLabel.enabled = NO;
        }
    }
}

#pragma mark - Single selection list delegate
- (void)singleSelectionListViewControllerDidFinish:(SingleSelectionListViewController *)controller withSelectedItem:(NSDictionary *)selectedItem {
    
    if ([self.selectionListMode isEqualToString:@"Calendar"]) {
        
        self.selectedCalendarIndex = [self calendarIndexForTitle:selectedItem[@"displayName"]];
        self.selectedCalendarId = selectedItem[@"uniqueId"];
        self.selectedCalendarTitle = selectedItem[@"displayName"];
        [self populateSelectedCalendar];
        
    } else if ([self.selectionListMode isEqualToString:@"AppointmentAlert"]) {
        
        self.selectedAppointmentAlertIndex = [self alertIndexForValue:selectedItem[@"uniqueId"]];
        self.selectedAppointmentAlertValue = selectedItem[@"uniqueId"];
        [self populateSelectedAppointmentAlert];
        
    }  else  if ([self.selectionListMode isEqualToString:@"CheckupInterval"]) {
        
        self.selectedCheckupIntervalIndex = [self checkupIntervalIndexForValue:selectedItem[@"uniqueId"]];
        self.selectedCheckupIntervalValue = selectedItem[@"uniqueId"];
        [self populateSelectedCheckupInterval];
        
    } else  if ([self.selectionListMode isEqualToString:@"CheckupAlert"]) {
        
        self.selectedCheckupAlertIndex = [self alertIndexForValue:selectedItem[@"uniqueId"]];
        self.selectedCheckupAlertValue = selectedItem[@"uniqueId"];
        [self populateSelectedCheckupAlert];
        
    }
    
    self.returnedFromPopoverOrView = YES;
}

#pragma mark - Bar button item actions
- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    
    BOOL validated = YES;
    
    if ([self.patientTitle.text isEqualToString:@"Please Select"]) {
        [self wobbleView:self.patientTitle];
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
    
    if ([self.patientDateOfBirth.text isEqualToString:@"Please Select"]) {
        [self wobbleView:self.patientDateOfBirth];
        validated = NO;
    }

    if (validated) {

        Patient *returnedPatient;
        
        if (self.editingPatient) {
            
            // Save edited patient
            [self.editingPatient setPatientTitle:self.patientTitle.text];
            [self.editingPatient setFirstName:self.firstName.text];
            [self.editingPatient setOtherNames:self.middleNames.text];
            [self.editingPatient setLastName:self.lastName.text];
            [self.editingPatient setDateOfBirth:self.selectedDateOfBirth];
            [self.editingPatient setAddAppointmentEvents:[NSNumber numberWithBool:self.appointmentReminderSwitch.isOn]];
            [self.editingPatient setCalendarId:self.selectedCalendarId];
            [self.editingPatient setCalendarTitle:self.selectedCalendarTitle];
            [self.editingPatient setAppointmentAlert:self.selectedAppointmentAlertValue];
            [self.editingPatient setAddCheckupEvents:[NSNumber numberWithBool:self.checkupReminderSwitch.isOn]];
            [self.editingPatient setCheckupInterval:self.selectedCheckupIntervalValue];
            [self.editingPatient setCheckupAlert:self.selectedCheckupAlertValue];
            
            // If we have switched off appointment events, delete unattended appointment events from calendar
            if (![self.appointmentReminderSwitch isOn]) {
                
                for (Appointment *appointment in self.editingPatient.appointments) {
                    
                    NSString *appointmentEventId = appointment.eventId;
                    if (appointmentEventId != nil &&
                        ![appointment.attended boolValue]) {
                        
                        EKEvent *appointmentEvent = [self.appDelegate.eventStore eventWithIdentifier:appointmentEventId];
                        
                        if (appointmentEvent != nil) {
                            
                            NSError *error;
                            [self.appDelegate.eventStore removeEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&error];
                            appointment.eventId = nil;
                        }
                    }
                }
                
            } else {
                
                // If we have switched on appointment events, add events for unattended appointments
                for (Appointment *appointment in self.editingPatient.appointments) {
                    
                    if (![[appointment attended] boolValue]) {
                        
                        // Only create an event if the appointment doesn't already have one
                        if ([self.appDelegate.eventStore eventWithIdentifier:appointment.eventId] == nil) {
                            
                            // Create event
                            EKEvent *appointmentEvent = [EKEvent eventWithEventStore:self.appDelegate.eventStore];
                            
                            // Set event properties
                            [appointmentEvent setTitle:@"Dentist Appointment"];
                            [appointmentEvent setLocation:[NSString stringWithFormat:@"%@", appointment.teamMember.fullNameWithTitle]];
                            [appointmentEvent setStartDate:appointment.dateTime];
                            [appointmentEvent setEndDate:[appointment.dateTime dateByAddingTimeInterval:(NSTimeInterval)[appointment.duration doubleValue]]];
                            
                            if ([self.appDelegate.eventStore calendarWithIdentifier:self.editingPatient.calendarId] == nil) {
                                
                                // If calendar no longer exists, update patient's calendar id and title with defaultCalendarForNewEvents' identifier and title
                                EKCalendar *defaultCalendar = [self.appDelegate.eventStore defaultCalendarForNewEvents];
                                self.editingPatient.calendarId = defaultCalendar.calendarIdentifier;
                                self.editingPatient.calendarTitle = defaultCalendar.title;
                            }
                            
                            [appointmentEvent setCalendar:[self.appDelegate.eventStore calendarWithIdentifier:self.editingPatient.calendarId]];
                            [appointmentEvent setNotes:appointment.note.note];
                            
                            if ([[self.editingPatient appointmentAlert] boolValue]) {
                                
                                [appointmentEvent addAlarm:[EKAlarm alarmWithRelativeOffset:-(NSTimeInterval)[self.editingPatient.appointmentAlert doubleValue]]];
                            }
                            
                            // Save event
                            NSError *eventError;
                            [self.appDelegate.eventStore saveEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&eventError];
                            
                            // Store calendar event identifier in appointment
                            [appointment setEventId:appointmentEvent.eventIdentifier];
                        }
                        
                    }
                }
            }
            
            // If we have switched off checkup reminder events, delete event from calendar
            if (![self.checkupReminderSwitch isOn] ||
                [self.selectedCheckupIntervalValue isEqualToNumber:@0]) {
                
                NSString *checkupReminderEventId = self.editingPatient.checkupEventId;
                if (checkupReminderEventId != nil) {
                    
                    EKEvent *checkupEvent = [self.appDelegate.eventStore eventWithIdentifier:checkupReminderEventId];
                    
                    if (checkupEvent != nil) {
                        NSError *error;
                        [self.appDelegate.eventStore removeEvent:checkupEvent span:EKSpanFutureEvents commit:YES error:&error];
                    }
                }
            }
            
            // Add checkup reminder calendar event
            if ([self.checkupReminderSwitch isOn] &&
                ![self.selectedCheckupIntervalValue isEqualToNumber:@0]) {
                
                // If there is already a checkup reminder in calendar, delete it
                NSString *checkupReminderEventId = self.editingPatient.checkupEventId;
                if (checkupReminderEventId != nil) {
                    
                    EKEvent *checkupEvent = [self.appDelegate.eventStore eventWithIdentifier:checkupReminderEventId];
                    
                    if (checkupEvent != nil) {
                        NSError *error;
                        [self.appDelegate.eventStore removeEvent:checkupEvent span:EKSpanFutureEvents commit:YES error:&error];
                    }
                }
                
                // Create new checkup reminder event
                EKEvent *checkupReminderEvent = [EKEvent eventWithEventStore:self.appDelegate.eventStore];
                
                // Set event properties
                [checkupReminderEvent setTitle:@"Dental Checkup Due"];
                [checkupReminderEvent setLocation:[DentalPractice dentalPracticeName]];
                
                [checkupReminderEvent setStartDate:[[Appointment dateOfLastAppointment] dateByAddingTimeInterval:[self.selectedCheckupIntervalValue doubleValue]]];
                [checkupReminderEvent setEndDate:[[Appointment dateOfLastAppointment] dateByAddingTimeInterval:[self.selectedCheckupIntervalValue doubleValue]]];
                [checkupReminderEvent setAllDay:YES];
                
                if ([self.appDelegate.eventStore calendarWithIdentifier:self.editingPatient.calendarId] == nil) {
                    
                    // If calendar no longer exists, update patient's calendar id and title with defaultCalendarForNewEvents' identifier and title
                    EKCalendar *defaultCalendar = [self.appDelegate.eventStore defaultCalendarForNewEvents];
                    self.editingPatient.calendarId = defaultCalendar.calendarIdentifier;
                    self.editingPatient.calendarTitle = defaultCalendar.title;
                }
                
                [checkupReminderEvent setCalendar:[self.appDelegate.eventStore calendarWithIdentifier:self.editingPatient.calendarId]];
                
                [checkupReminderEvent setNotes:@"Your regular dental checkup is due."];
                
                if (![[self.editingPatient checkupAlert] isEqualToNumber:@-1]) {
                    
                    [checkupReminderEvent addAlarm:[EKAlarm alarmWithRelativeOffset:-(NSTimeInterval)[self.editingPatient.checkupAlert doubleValue]]];
                }
                
                // Save event
                NSError *eventError;
                [self.appDelegate.eventStore saveEvent:checkupReminderEvent span:EKSpanFutureEvents commit:YES error:&eventError];
                
                // Store calendar event identifier in patient
                [self.editingPatient setCheckupEventId:checkupReminderEvent.eventIdentifier];
                
            }
            
            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            returnedPatient = self.editingPatient;
            
        } else {
            
            // Create patient
            Patient *patient = (Patient *)[NSEntityDescription insertNewObjectForEntityForName:@"Patient" inManagedObjectContext:self.managedObjectContext];
            
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [patient setUniqueId:uuid];
            
            [patient setPatientTitle:self.patientTitle.text];
            [patient setFirstName:self.firstName.text];
            [patient setOtherNames:self.middleNames.text];
            [patient setLastName:self.lastName.text];
            [patient setDateOfBirth:self.selectedDateOfBirth];
            [patient setAddAppointmentEvents:[NSNumber numberWithBool:self.appointmentReminderSwitch.isOn]];
            [patient setCalendarId:self.selectedCalendarId];
            [patient setCalendarTitle:self.selectedCalendarTitle];
            [patient setAppointmentAlert:self.selectedAppointmentAlertValue];
            [patient setAddCheckupEvents:[NSNumber numberWithBool:self.checkupReminderSwitch.isOn]];
            [patient setCheckupInterval:self.selectedCheckupIntervalValue];
            [patient setCheckupAlert:self.selectedCheckupAlertValue];
            
            // Create teeth for this patient
            NSMutableOrderedSet *newTeethSet = [[NSMutableOrderedSet alloc] init];
            NSString *toothNamesPlistPath = [[NSBundle mainBundle] pathForResource:@"Tooth Names" ofType:@"plist"];
            NSDictionary *teethNamesDict = [[NSDictionary alloc] initWithContentsOfFile:toothNamesPlistPath];
            NSArray *toothNames = teethNamesDict[@"Teeth"];
            
            // Upper left teeth
            int toothCounter = 8;
            for (NSString *toothName in [toothNames reverseObjectEnumerator]) {
                
                NSString *toothReference = [NSString stringWithFormat:@"UL%i",toothCounter];
                
                Tooth *newTooth = (Tooth *)[NSEntityDescription insertNewObjectForEntityForName:@"Tooth" inManagedObjectContext:self.managedObjectContext];
                
                newTooth.name = toothName;
                newTooth.reference = toothReference;
                newTooth.patient = patient;
                
                newTooth.frontImage = [NSString stringWithFormat:@"UL%i_front", toothCounter];
                newTooth.topImage = [NSString stringWithFormat:@"UL%i_top", toothCounter];
                
                [newTeethSet addObject:newTooth];
                
                toothCounter--;
            }
            
            // Upper right teeth
            toothCounter++;
            for (NSString *toothName in toothNames) {
                
                NSString *toothReference = [NSString stringWithFormat:@"UR%i", toothCounter];
                
                Tooth *newTooth = (Tooth *)[NSEntityDescription insertNewObjectForEntityForName:@"Tooth" inManagedObjectContext:self.managedObjectContext];
                
                newTooth.name = toothName;
                newTooth.reference = toothReference;
                newTooth.patient = patient;
                
                newTooth.frontImage = [NSString stringWithFormat:@"UR%i_front", toothCounter];
                newTooth.topImage = [NSString stringWithFormat:@"UR%i_top", toothCounter];
                
                [newTeethSet addObject:newTooth];
                
                toothCounter++;
            }
            
            // Lower left teeth
            toothCounter--;
            for (NSString *toothName in [toothNames reverseObjectEnumerator]) {
                
                NSString *toothReference = [NSString stringWithFormat:@"LL%i",toothCounter];
                
                Tooth *newTooth = (Tooth *)[NSEntityDescription insertNewObjectForEntityForName:@"Tooth" inManagedObjectContext:self.managedObjectContext];
                
                newTooth.name = toothName;
                newTooth.reference = toothReference;
                newTooth.patient = patient;
                
                newTooth.frontImage = [NSString stringWithFormat:@"LL%i_front", toothCounter];
                newTooth.topImage = [NSString stringWithFormat:@"LL%i_top", toothCounter];
                
                [newTeethSet addObject:newTooth];
                
                toothCounter--;
            }
            
            // Lower right teeth
            toothCounter++;
            for (NSString *toothName in toothNames) {
                
                NSString *toothReference = [NSString stringWithFormat:@"LR%i",toothCounter];
                
                Tooth *newTooth = (Tooth *)[NSEntityDescription insertNewObjectForEntityForName:@"Tooth" inManagedObjectContext:self.managedObjectContext];
                
                newTooth.name = toothName;
                newTooth.reference = toothReference;
                newTooth.patient = patient;
                
                newTooth.frontImage = [NSString stringWithFormat:@"LR%i_front", toothCounter];
                newTooth.topImage = [NSString stringWithFormat:@"LR%i_top", toothCounter];
                
                [newTeethSet addObject:newTooth];
                
                ++toothCounter;
            }
            
            [patient setTeeth:newTeethSet];
            
            // Add checkup reminder calendar event
            if ([self.checkupReminderSwitch isOn] &&
                ![self.selectedCheckupIntervalValue isEqualToNumber:@0]) {
                
                // Create event
                EKEvent *checkupReminderEvent = [EKEvent eventWithEventStore:self.appDelegate.eventStore];
                
                // Set event properties
                [checkupReminderEvent setTitle:@"Dental Checkup Due"];
                [checkupReminderEvent setLocation:[DentalPractice dentalPracticeName]];
                
                [checkupReminderEvent setStartDate:[[Appointment dateOfLastAppointment] dateByAddingTimeInterval:[self.selectedCheckupIntervalValue doubleValue]]];
                [checkupReminderEvent setEndDate:[[Appointment dateOfLastAppointment] dateByAddingTimeInterval:[self.selectedCheckupIntervalValue doubleValue]]];
                [checkupReminderEvent setAllDay:YES];
                
                if ([self.appDelegate.eventStore calendarWithIdentifier:patient.calendarId] == nil) {
                    
                    // If calendar no longer exists, update patient's calendar id and title with defaultCalendarForNewEvents' identifier and title
                    EKCalendar *defaultCalendar = [self.appDelegate.eventStore defaultCalendarForNewEvents];
                    patient.calendarId = defaultCalendar.calendarIdentifier;
                    patient.calendarTitle = defaultCalendar.title;
                }
                
                [checkupReminderEvent setCalendar:[self.appDelegate.eventStore calendarWithIdentifier:patient.calendarId]];
                
                [checkupReminderEvent setNotes:@"Your regular dental checkup is due."];
                
                if (![[patient checkupAlert] isEqualToNumber:@-1]) {
                    
                    [checkupReminderEvent addAlarm:[EKAlarm alarmWithRelativeOffset:-(NSTimeInterval)[patient.checkupAlert doubleValue]]];
                }
                
                // Save event
                NSError *eventError;
                [self.appDelegate.eventStore saveEvent:checkupReminderEvent span:EKSpanThisEvent commit:YES error:&eventError];
                
                // Store calendar event identifier in patient
                [patient setCheckupEventId:checkupReminderEvent.eventIdentifier];
                
            }
            
            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            returnedPatient = patient;
        }
        
        // If this is the only patient, store the object id in user defaults
        if ([Patient numberOfPatients] == 1) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setURL:[returnedPatient.objectID URIRepresentation]
                      forKey:@"selectedPatientObjectId"];
            
            [defaults synchronize];
        }
        
        [self.delegate addPatientViewControllerDidFinishWithPatient:(Patient *)returnedPatient];
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