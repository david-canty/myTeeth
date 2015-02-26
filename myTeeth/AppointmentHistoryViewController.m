//
//  AppointmentHistoryViewController.m
//  myTeeth
//
//  Created by David Canty on 23/02/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "AppointmentHistoryViewController.h"
#import "Appointment+Utils.h"
#import "TeamMember+Utils.h"
#import "AppointmentCell.h"
#import "AddAppointmentViewController.h"

static NSString *kAppointmentHistoryTableCellIdentifier = @"AppointmentHistoryTableCellIdentifier";

@interface AppointmentHistoryViewController () <NSFetchedResultsControllerDelegate, AddAppointmentViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Appointment *selectedAppointment;

@end

@implementation AppointmentHistoryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ShowAddAppointmentView"]) {
    
        [super prepareForSegue:segue sender:sender];
    }
    if ([[segue identifier] isEqualToString:@"ShowViewAppointmentView"]) {
        
        AddAppointmentViewController *controller = (AddAppointmentViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.navigationItem.title = NSLocalizedString(@"Appointment", @"Appointment");
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
        
        // Set appointment to be viewed
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedAppointment = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        controller.appointment = self.selectedAppointment;
        controller.viewingAppointment = YES;
    }
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppointmentCell *cell = (AppointmentCell *)[tableView dequeueReusableCellWithIdentifier:kAppointmentHistoryTableCellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(AppointmentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Appointment *appointment = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [cell.cellTickButton addTarget:self action:@selector(cellTickButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.cellNameLabel.text = [appointment.teamMember fullNameWithTitle];
    
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [outputDateFormatter setDateFormat:@"eee d MMM yyyy 'at' h:mm a"];
    NSString *dateTimeString = [outputDateFormatter stringFromDate:appointment.dateTime];
    cell.cellDateTimeLabel.text = dateTimeString;
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Only show appointments that have not been attended
    NSPredicate *attendedPredicate = [NSPredicate predicateWithFormat:@"attended = %@", @YES];
    [fetchRequest setPredicate:attendedPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - Add appointment delegate
- (void)addAppointmentViewControllerDidCancel:(AddAppointmentViewController *)controller {
    
    if (controller.appointment) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAppointmentViewControllerDidFinish:(AddAppointmentViewController *)controller {
    
    if (controller.appointment) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end