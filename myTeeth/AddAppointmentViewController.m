//
//  AddAppointmentViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 13/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "AddAppointmentViewController.h"
#import "Constants.h"
#import "SingleSelectionListViewController.h"
#import "MultipleSelectionListViewController.h"
#import "DateTimeViewController.h"
#import "DurationViewController.h"
#import "Patient+Utils.h"
#import "TeamMember+Utils.h"
#import "TreatmentCategory+Utils.h"
#import "TreatmentItem+Utils.h"
#import "Appointment+Utils.h"
#import "NoteViewController_iPad.h"
#import "Note+Utils.h"
#import "ChargeType+Utils.h"
#import "AddPatientViewController.h"
#import "AddTeamMemberViewController.h"
#import "ChargeTypeDetailViewController_iPad.h"
#import "AppDelegate.h"

@interface AddAppointmentViewController () <SingleSelectionListViewControllerDelegate, MultipleSelectionListViewControllerDelegate, DateTimeViewControllerDelegate, DurationViewControllerDelegate, NSFetchedResultsControllerDelegate, NoteViewControllerDelegate, AddPatientViewControllerDelegate, AddTeamMemberViewControllerDelegate, ChargeTypeDetailViewControllerDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *patientList;
@property (strong, nonatomic) NSArray *teamMemberList;
@property (strong, nonatomic) NSArray *chargeTypeList;
@property (strong, nonatomic) NSArray *treatmentSelectionListItems;

@property (strong, nonatomic) NSDictionary *selectedPatient;
@property (strong, nonatomic) NSDictionary *selectedTeamMember;
@property (strong, nonatomic) NSDate *selectedDate;
@property (assign, nonatomic) NSTimeInterval selectedDuration;
@property (strong, nonatomic) NSArray *selectedTreatmentItems;
@property (strong, nonatomic) NSDictionary *selectedChargeType;
@property (copy, nonatomic) NSString *noteString;

@property (weak, nonatomic) IBOutlet UITableViewCell *patientCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *teamMemberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *durationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *treatmentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chargeTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *notesCell;

- (IBAction)done:(id)sender;

@end

static NSTimeInterval const kDefaultDuration = 600;

@implementation AddAppointmentViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.viewingAppointment = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Pre-populate values if editing appointment
    if (self.appointment) {
        
        // Patient
        self.selectedPatient = @{@"displayName" : [self.appointment.patient fullNameWithTitle],
                                 @"uniqueId" : self.appointment.patient.uniqueId};
        
        // Team Member
        self.selectedTeamMember = @{@"displayName" : [self.appointment.teamMember fullNameWithTitle],
                                    @"uniqueId" : self.appointment.teamMember.uniqueId};
        
        // Date and Time
        self.selectedDate = self.appointment.dateTime;
        
        // Duration
        self.selectedDuration = (NSTimeInterval)[self.appointment.duration doubleValue];
        
        // Treatment
        NSMutableArray *selectedTreatmentItems = [@[] mutableCopy];
        for (TreatmentItem *treatmentItem in self.appointment.treatmentItems) {
            
            NSDictionary *treatmentItemDict = @{@"displayName" : treatmentItem.itemName,
                                                @"uniqueId" : treatmentItem.uniqueId,
                                                @"sectionHeader" : treatmentItem.treatmentCategory.categoryName};
            [selectedTreatmentItems addObject:treatmentItemDict];
        }
        self.selectedTreatmentItems = selectedTreatmentItems;
        
        // Charge Type
        self.selectedChargeType = @{@"displayName" : self.appointment.chargeType.typeName,
                                    @"uniqueId" : self.appointment.chargeType.uniqueId};
        
        // Notes
        self.noteString = self.appointment.note.note;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Pre-populate fields if editing appointment
    if (self.appointment) {

        // Patient
        [self displaySelectedPatient];
        
        // Team Member
        [self displaySelectedTeamMember];
        
        // Date and Time
        [self populateDateDetailLabel];
        
        // Duration
        [self displaySelectedDuration];
        
        // Treatment
        [self displaySelectedTreatmentItems];
        
        // Charge Type
        [self displaySelectedChargeType];
        
        // Notes
        [self displayNote];
        
    } else {
        
        // Default to patient if only one
        if ([Patient numberOfPatients] == 1) {
            
            [self fetchPatients];
            self.selectedPatient = self.patientList[0];
            [self displaySelectedPatient];
        }
        
        // Default to team member if only one
        if ([TeamMember numberOfTeamMembers] == 1) {
            
            [self fetchTeamMembers];
            self.selectedTeamMember = self.teamMemberList[0];
            [self displaySelectedTeamMember];
        }
        
        // Default to charge type if only one
        if ([ChargeType numberOfChargeTypes] == 1) {
            
            [self fetchChargeTypes];
            self.selectedChargeType = self.chargeTypeList[0];
            [self displaySelectedChargeType];
        }
        
        // Default duration
        self.selectedDuration = kDefaultDuration;
        [self displaySelectedDuration];
    }
    
    if (self.viewingAppointment) {
        
        // Disable fields when viewing
        self.patientCell.userInteractionEnabled = NO;
        self.patientCell.accessoryType = UITableViewCellAccessoryNone;
        self.teamMemberCell.userInteractionEnabled = NO;
        self.teamMemberCell.accessoryType = UITableViewCellAccessoryNone;
        self.dateTimeCell.userInteractionEnabled = NO;
        self.dateTimeCell.accessoryType = UITableViewCellAccessoryNone;
        self.durationCell.userInteractionEnabled = NO;
        self.durationCell.accessoryType = UITableViewCellAccessoryNone;
        self.treatmentCell.userInteractionEnabled = NO;
        self.treatmentCell.accessoryType = UITableViewCellAccessoryNone;
        self.chargeTypeCell.userInteractionEnabled = NO;
        self.chargeTypeCell.accessoryType = UITableViewCellAccessoryNone;
        
        UIBarButtonItem *billButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bill", @"Bill") style:UIBarButtonItemStyleBordered target:self action:@selector(billButtonTapped:)];
        NSArray *toolbarItems = @[billButton];
        [self setToolbarItems:toolbarItems];
        [self.navigationController setToolbarHidden:NO animated:NO];
        
    } else {
        
        // Only add cancel button if we are adding or editing an appointment
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"ShowSelectPatientView"]) {
        
        if ([Patient numberOfPatients] == 0) {
            
            // No patients, so add one
            [self performSegueWithIdentifier:@"ShowAddPatientView" sender:nil];
            
            return NO;
        }
    }
    
    if ([identifier isEqualToString:@"ShowSelectTeamMemberView"]) {
        
        if ([TeamMember numberOfTeamMembers] == 0) {
            
            // No team members, so add one
            [self performSegueWithIdentifier:@"ShowAddTeamMemberView" sender:nil];
            
            return NO;
        }
    }
    
    if ([identifier isEqualToString:@"ShowSelectChargeTypeView"]) {
        
        if ([ChargeType numberOfChargeTypes] == 0) {
            
            // No charge types, so add one
            [self performSegueWithIdentifier:@"ShowAddChargeTypeView" sender:nil];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowAddPatientView"]) {
        
        AddPatientViewController *addController = (AddPatientViewController *)segue.destinationViewController;
        addController.navigationItem.title = NSLocalizedString(@"Add Patient", @"Add Patient");
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowAddTeamMemberView"]) {
        
        AddTeamMemberViewController *addController = (AddTeamMemberViewController *)segue.destinationViewController;
        addController.navigationItem.title = NSLocalizedString(@"Add Team Member", @"Add Team Member");
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowAddChargeTypeView"]) {
        
        ChargeTypeDetailViewController_iPad *addController = (ChargeTypeDetailViewController_iPad *)segue.destinationViewController;
        addController.navigationItem.title = NSLocalizedString(@"Add Charge Type", @"Add Charge Type");
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowSelectPatientView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Patient", @"Patient");
        
        [self fetchPatients];
        
        selectionListViewController.selectionList = self.patientList;
        
        // Pre-select patient if already selected
        if (self.selectedPatient != nil) {
            
            NSInteger selectedPatientIndex = [self.patientList indexOfObject:self.selectedPatient];
            selectionListViewController.initialSelection = selectedPatientIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a patient for this appointment", @"Please select a patient for this appointment");
    }
    
    if ([[segue identifier] isEqualToString:@"ShowSelectTeamMemberView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Team Member", @"Team Member");

        [self fetchTeamMembers];
        
        selectionListViewController.selectionList = self.teamMemberList;
        
        // Pre-select team member if already selected
        if (self.selectedTeamMember != nil) {
            
            NSInteger selectedTeamMemberIndex = [self.teamMemberList indexOfObject:self.selectedTeamMember];
            selectionListViewController.initialSelection = selectedTeamMemberIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a team member for this appointment", @"Please select a team member for this appointment");
    }
    
    if ([[segue identifier] isEqualToString:@"ShowDateTimeView"]) {
        
        DateTimeViewController *dateTimeController = [segue destinationViewController];
        dateTimeController.navigationItem.title = NSLocalizedString(@"Date and Time", @"Date and Time");
        dateTimeController.delegate = self;
        
        // Pre-select date and time if already selected
        if (self.selectedDate) {
            
            dateTimeController.datePickerDate = [self roundDate:self.selectedDate];
            
        } else {
            
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:floor([NSDate timeIntervalSinceReferenceDate])];
            dateTimeController.datePickerDate = [self roundDate:currentDate];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"ShowDurationView"]) {
        
        DurationViewController *durationController = [segue destinationViewController];
        durationController.navigationItem.title = NSLocalizedString(@"Duration", @"Duration");
        durationController.delegate = self;
        
        // Pre-select duration if already selected
        if (self.selectedDuration > 0) {
            
            durationController.pickerDuration = self.selectedDuration;
        }
    }
    
    if ([[segue identifier] isEqualToString:@"ShowTreatmentView"]) {
        
        MultipleSelectionListViewController *multipleSelectionListViewController = [segue destinationViewController];
        multipleSelectionListViewController.navigationItem.title = NSLocalizedString(@"Treatment", @"Treatment");
        
        // Pre-select treatment items if already selected
        if (self.selectedTreatmentItems != nil) {
            
            multipleSelectionListViewController.selectedItems = [self.selectedTreatmentItems mutableCopy];
        }
        
        multipleSelectionListViewController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowSelectChargeTypeView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Charge Type", @"Charge Type");
        
        [self fetchChargeTypes];
        
        selectionListViewController.selectionList = self.chargeTypeList;
        
        // Pre-select charge type if already selected
        if (self.selectedChargeType != nil) {
            
            NSInteger selectedChargeTypeIndex = [self.chargeTypeList indexOfObject:self.selectedChargeType];
            selectionListViewController.initialSelection = selectedChargeTypeIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a charge type for this appointment", @"Please select a charge type for this appointment");
    }
    
    if ([[segue identifier] isEqualToString:@"ShowNoteView"]) {
    
        NoteViewController_iPad *noteViewController = [segue destinationViewController];
        noteViewController.navigationItem.title = NSLocalizedString(@"Note", @"Appointment Note");
        noteViewController.delegate = self;
        noteViewController.noteString = self.noteString;
    }
}

- (void)addPatientViewControllerDidFinishWithPatient:(Patient *)patient {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // Select added patient and update UI
    self.selectedPatient = @{@"displayName" : [patient fullNameWithTitle],
                                @"uniqueId" : patient.uniqueId};;
    [self displaySelectedPatient];
}

- (void)addTeamMemberViewControllerDidFinishWithTeamMember:(TeamMember *)teamMember {
    
    [self.navigationController popViewControllerAnimated:YES];

    // Select added team member and update UI
    self.selectedTeamMember = @{@"displayName" : [teamMember fullNameWithTitle],
                                @"uniqueId" : teamMember.uniqueId};;
    [self displaySelectedTeamMember];
}

- (void)chargeTypeDetailViewControllerDidFinishWithChargeType:(ChargeType *)chargeType {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // Select added charge type and update UI
    self.selectedChargeType = @{@"displayName" : [chargeType typeName],
                                @"uniqueId" : chargeType.uniqueId};;
    [self displaySelectedChargeType];
}

- (void)fetchPatients {
    
    if (self.patientList == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *patientEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *patients = [@[] mutableCopy];
        
        for (Patient *patientEntity in patientEntities) {
            
            [patients addObject:@{@"displayName" : [patientEntity fullNameWithTitle],
                                  @"uniqueId" : patientEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.patientList = [patients sortedArrayUsingDescriptors:@[descriptor]];
    }
}

- (void)fetchTeamMembers {
    
    if (self.teamMemberList == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamMember" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *teamMemberEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *teamMembers = [@[] mutableCopy];
        
        for (TeamMember *teamMemberEntity in teamMemberEntities) {
            
            [teamMembers addObject:@{@"displayName" : [teamMemberEntity fullNameWithTitle],
                                     @"uniqueId" : teamMemberEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.teamMemberList = [teamMembers sortedArrayUsingDescriptors:@[descriptor]];
    }
}

- (void)fetchChargeTypes {
    
    if (self.chargeTypeList == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChargeType" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *chargeTypeEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *chargeTypes = [@[] mutableCopy];
        
        for (ChargeType *chargeTypeEntity in chargeTypeEntities) {
            
            [chargeTypes addObject:@{@"displayName" : chargeTypeEntity.typeName,
                                     @"uniqueId" : chargeTypeEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.chargeTypeList = [chargeTypes sortedArrayUsingDescriptors:@[descriptor]];
    }
}

#define kMinuteInterval	5

- (NSDate *)roundDate:(NSDate *)dateToRound {
	// Create a NSDate object and a NSDateComponets object for us to use
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dateToRound];
	
	// Extract the number of minutes and find the remainder when divided the time interval
	NSInteger remainder = [dateComponents minute] % kMinuteInterval; // gives us the remainder when divided by interval (for example, 25 would be 0, but 23 would give a remainder of 3
	
	// Round to the nearest 5 minutes (ignoring seconds)
	if (remainder >= kMinuteInterval/2) {
        dateToRound = [dateToRound dateByAddingTimeInterval:((kMinuteInterval - remainder) * 60)]; // Add the difference
	} else if (remainder > 0 && remainder < kMinuteInterval/2) {
        dateToRound = [dateToRound dateByAddingTimeInterval:(remainder * -60)]; // Subtract the difference
	}
	
	// Subtract the number of seconds
	return [dateToRound dateByAddingTimeInterval:(-1 * [dateComponents second])];    
}

#pragma mark - Delegate methods

// table sections
#define APPPOINTMENT_DETAILS 0
#define PROPOSED_TREATMENT 1
#define APPOINTMENT_CHARGES 2
#define APPOINTMENT_NOTES 3

// table section rows
#define PATIENT 0
#define TEAM_MEMBER 1
#define DATE_AND_TIME 2
#define DURATION 3
#define TREATMENT 0
#define CHARGE_TYPE 0
#define NOTES 0

- (void)singleSelectionListViewControllerDidFinish:(SingleSelectionListViewController *)controller withSelectedItem:(NSDictionary *)selectedItem {
    
    if ([controller.navigationItem.title isEqualToString:myTeethPatient]) {
        
        self.selectedPatient = selectedItem;
        [self displaySelectedPatient];
    }
    
    if ([controller.navigationItem.title isEqualToString:myTeethTeamMember]) {
        
        self.selectedTeamMember = selectedItem;
        [self displaySelectedTeamMember];
    }
    
    if ([controller.navigationItem.title isEqualToString:myTeethChargeType]) {
        
        self.selectedChargeType = selectedItem;
        [self displaySelectedChargeType];
    }
}

- (void)displaySelectedPatient {
    
    NSUInteger index[] = {APPPOINTMENT_DETAILS, PATIENT};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = self.selectedPatient[@"displayName"];
}

- (void)displaySelectedTeamMember {

    NSUInteger index[] = {APPPOINTMENT_DETAILS, TEAM_MEMBER};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = self.selectedTeamMember[@"displayName"];
}

- (void)multipleSelectionListViewControllerDidFinish:(MultipleSelectionListViewController *)controller withSelectedItems:(NSArray *)selectedItems {
    
    if ([controller.navigationItem.title isEqualToString:myTeethTreatment]) {
        
        NSUInteger index[] = {PROPOSED_TREATMENT, TREATMENT};
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([selectedItems count] == 0) {
            
            cell.detailTextLabel.text = NSLocalizedString(kPleaseSelect, @"Please select");
            
        } else {
            
            self.selectedTreatmentItems = selectedItems;
            [self displaySelectedTreatmentItems];
        }
    }
}

- (NSArray *)getSelectionListItems {
    
    // load default treatment categories and items if not already loaded
    [TreatmentCategory loadDefaultTreatmentCategories];
    [TreatmentItem loadDefaultTreatmentItems];
    
    // get treatment categories
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:category];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    NSArray *treatmentCategories = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ((treatmentCategories != nil) && ([treatmentCategories count]) && (error == nil)) {
        
        // enumerate categories and get all respective treatment items
        NSMutableArray *treatmentSelectionListItems = [@[] mutableCopy];
        
        for (TreatmentCategory *category in treatmentCategories) {
            
            for (TreatmentItem *item in category.treatmentItems) {
                
                NSDictionary *treatmentItem = @{@"displayName" : item.itemName,
                                                @"uniqueId" : item.uniqueId,
                                                @"sectionHeader" : category.categoryName};
                
                [treatmentSelectionListItems addObject:treatmentItem];
            }
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.treatmentSelectionListItems = [treatmentSelectionListItems sortedArrayUsingDescriptors:@[descriptor]];
        return self.treatmentSelectionListItems;
    }
    
    return nil;
}

- (void)DateTimeViewControllerDidFinish:(DateTimeViewController *)controller WithDate:(NSDate *)date {
    
    self.selectedDate = date;
	[self populateDateDetailLabel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)populateDateDetailLabel {
    
    NSUInteger index[] = {APPPOINTMENT_DETAILS, DATE_AND_TIME};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
	[outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[outputDateFormatter setDateFormat:@"eeee d MMM yyyy 'at' h:mm a"];
	NSString *dateTimeString = [outputDateFormatter stringFromDate:self.selectedDate];
    cell.detailTextLabel.text = dateTimeString;
}

- (void)DurationViewControllerDidFinish:(DurationViewController *)controller WithDuration:(NSTimeInterval)duration {
    
    self.selectedDuration = duration;
    [self displaySelectedDuration];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displaySelectedDuration {
    
    NSUInteger index[] = {APPPOINTMENT_DETAILS, DURATION};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self formatInterval:self.selectedDuration];
}

- (void)displaySelectedChargeType {
    
    NSUInteger index[] = {APPOINTMENT_CHARGES, CHARGE_TYPE};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                 self.selectedChargeType[@"displayName"]];
}

- (void)displaySelectedTreatmentItems {
    
    NSMutableString *selectedTreatmentItemsString = [[NSMutableString alloc] init];
    NSInteger selectedItemCount = 0;
    for (NSDictionary *selectedItem in self.selectedTreatmentItems) {
        
        [selectedTreatmentItemsString appendString:selectedItem[@"displayName"]];
        ++selectedItemCount;
        if ([selectedTreatmentItemsString length] > 0 && selectedItemCount < [self.selectedTreatmentItems count]) {
            
            [selectedTreatmentItemsString appendString:@", "];
        }
    }
    
    NSUInteger index[] = {PROPOSED_TREATMENT, TREATMENT};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = selectedTreatmentItemsString;
}

- (void)displayNote {
    
    NSUInteger index[] = {APPOINTMENT_NOTES, NOTES};
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:index length:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![self.noteString isEqualToString:@""]) {
        
        cell.detailTextLabel.text = self.noteString;
        
    } else {
        
        cell.detailTextLabel.text = kOptional;
    }
}

- (NSString *)formatInterval:(NSTimeInterval)interval {
    
	NSMutableString *result = [[NSMutableString alloc] init];
	if (interval == 60) {
        
		[result setString:@"0 mins"];
        
	} else {
        
		unsigned long seconds = interval;
		unsigned long minutes = seconds / 60;
		seconds %= 60;
		unsigned long hours = minutes / 60;
		minutes %= 60;
		if (hours > 0) {
            
			if (hours == 1) {
                
				[result appendFormat: @"%lu hour ", hours];
                
			} else {
                
				[result appendFormat: @"%lu hours ", hours];
			}
		}
		[result appendFormat:@"%lu mins", minutes];
	}
	return result;
}

- (void)noteViewControllerDelegateDidFinish:(NoteViewController_iPad *)controller withNote:(NSString *)note {
    
    if (![note isEqualToString:self.noteString]) {
        
        // Add cancel button in case we need to discard note edits
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    self.noteString = note;
    [self displayNote];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Add appointment delegate methods
- (void)cancel:(id)sender {
    
    // Call delegate did cancel
    [[self delegate] addAppointmentViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    
    if ([self validateFields]) {
        
        // Save appointment
        Appointment *appointment;
        
        if (self.appointment) {
            
            appointment = self.appointment;
            
        } else {
        
            appointment = (Appointment *)[NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext];
            
            // Unique id
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [appointment setUniqueId:uuid];
            
        }

        // Patient
        Patient *patient = [Patient patientWithUniqueId:self.selectedPatient[@"uniqueId"]];
        [appointment setPatient:patient];
        
        // Team member
        TeamMember *teamMember = [TeamMember teamMemberWithUniqueId:self.selectedTeamMember[@"uniqueId"]];
        [appointment setTeamMember:teamMember];
        
        // Date and time
        [appointment setDateTime:self.selectedDate];
        
        // Duration
        [appointment setDuration:[NSNumber numberWithDouble:self.selectedDuration]];
        
        // Treatment
        for (NSDictionary *treatmentItemDict in self.selectedTreatmentItems) {
            
            TreatmentItem *treatmentItem = [TreatmentItem treatmentItemWithUniqueID:treatmentItemDict[@"uniqueId"]];
            [appointment addTreatmentItemsObject:treatmentItem];
        }
        
        // Charge type
        ChargeType *chargeType = [ChargeType chargeTypeWithUniqueId:self.selectedChargeType[@"uniqueId"]];
        [appointment setChargeType:chargeType];
        
        // Note
        if (![self.noteString isEqualToString:@""]) {
            Note *appointmentNote = [Note noteWithString:self.noteString];
            [appointment setNote:appointmentNote];
        }
        
        // Add calendar event
        if ([[patient addAppointmentEvents] boolValue]) {
            
            // Delete existing appointment calendar event if there is one
            if (appointment.eventId != nil) {
                
                EKEvent *appointmentEvent = [self.appDelegate.eventStore eventWithIdentifier:appointment.eventId];
                
                if (appointmentEvent != nil) {
                    
                    NSError *error;
                    [self.appDelegate.eventStore removeEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&error];
                }
                
                appointment.eventId = nil;
            }
            
            // Create event
            EKEvent *appointmentEvent = [EKEvent eventWithEventStore:self.appDelegate.eventStore];
            
            // Set event properties
            [appointmentEvent setTitle:@"Dentist Appointment"];
            [appointmentEvent setLocation:[NSString stringWithFormat:@"%@", teamMember.fullNameWithTitle]];
            [appointmentEvent setStartDate:self.selectedDate];
            [appointmentEvent setEndDate:[self.selectedDate dateByAddingTimeInterval:self.selectedDuration]];
            
            if ([self.appDelegate.eventStore calendarWithIdentifier:patient.calendarId] == nil) {
                
                // If calendar no longer exists, update patient's calendar id and title with defaultCalendarForNewEvents' identifier and title
                EKCalendar *defaultCalendar = [self.appDelegate.eventStore defaultCalendarForNewEvents];
                patient.calendarId = defaultCalendar.calendarIdentifier;
                patient.calendarTitle = defaultCalendar.title;
            }
            
            [appointmentEvent setCalendar:[self.appDelegate.eventStore calendarWithIdentifier:patient.calendarId]];
            
            [appointmentEvent setNotes:self.noteString];
            
            if ([[patient appointmentAlert] boolValue]) {
                
                [appointmentEvent addAlarm:[EKAlarm alarmWithRelativeOffset:-(NSTimeInterval)[patient.appointmentAlert doubleValue]]];
            }
            
            // Save event
            NSError *eventError;
            [self.appDelegate.eventStore saveEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&eventError];
            
            // Store calendar event identifier in appointment
            [appointment setEventId:appointmentEvent.eventIdentifier];
            
        }
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        // Call delegate did finish
        [[self delegate] addAppointmentViewControllerDidFinish:self];
    }
}

- (BOOL)validateFields {
    
    BOOL isValidated = YES;
    
    if ([self.patientCell.detailTextLabel.text isEqualToString:kPleaseSelect]) {
        
        [self wobbleCell:self.patientCell];
        isValidated = NO;
        
    } else if ([self.teamMemberCell.detailTextLabel.text isEqualToString:kPleaseSelect]) {
        
        [self wobbleCell:self.teamMemberCell];
        isValidated = NO;
        
    } else if ([self.dateTimeCell.detailTextLabel.text isEqualToString:kPleaseSelect]) {
        
        [self wobbleCell:self.dateTimeCell];
        isValidated = NO;
        
    } else if ([self.treatmentCell.detailTextLabel.text isEqualToString:kPleaseSelect]) {
        
        [self wobbleCell:self.treatmentCell];
        isValidated = NO;
        
    } else if ([self.chargeTypeCell.detailTextLabel.text isEqualToString:kPleaseSelect]) {
        
        [self wobbleCell:self.chargeTypeCell];
        isValidated = NO;
    }
    
    return isValidated;
}

- (void)wobbleCell:(UITableViewCell *)cellToWobble {
    
    CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
    wobble.autoreverses = YES;
    wobble.repeatCount = 2.0f;
    wobble.duration = 0.10f;
    [cellToWobble.detailTextLabel.layer addAnimation:wobble forKey:nil];
}

#pragma mark - Toolbar button actions
- (void)billButtonTapped:(id)sender {
    
    // remove check box from cell - new cell needed
    
    // Push bill view controller (show Cancel button if changes made)
    

}

@end