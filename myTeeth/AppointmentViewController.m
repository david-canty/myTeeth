//
//  AppointmentViewController.m
//  myTeeth
//
//  Created by David Canty on 16/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "AppointmentViewController.h"
#import "Appointment+Utils.h"
#import "AppointmentCell.h"
#import "TeamMember+Utils.h"
#import "AddAppointmentViewController.h"
#import "BillViewController.h"
#import "AppDelegate.h"

static NSString *appointmentTableCellIdentifier = @"AppointmentTableCellIdentifier";

@interface AppointmentViewController () <NSFetchedResultsControllerDelegate, AddAppointmentViewControllerDelegate, BillViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Appointment *selectedAppointment;

@end

@implementation AppointmentViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAppointment)];
    NSArray *myToolbarItems = @[addButton];
    [self setToolbarItems:myToolbarItems];
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:NO animated:YES];
    
    if ([Appointment numberOfAppointments] == 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)addAppointment {

    [self performSegueWithIdentifier:@"ShowAddAppointmentView" sender:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:YES animated:YES];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppointmentCell *cell = (AppointmentCell *)[tableView dequeueReusableCellWithIdentifier:appointmentTableCellIdentifier];
    
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

- (void)cellTickButtonTapped:(id)sender {
    
    // Get appointment
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Appointment *appointment = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    // If appointment date and time has passed, mark appointment as attended
    if ([appointment.dateTime compare:[NSDate date]] == NSOrderedAscending) {
        
        // Request to create bill if payment method is pay per appointment or pay per course of treatment
        // if ...
        [self requestBillForAppointment:appointment atIndexPath:indexPath withTickButton:(UIButton *)sender];
        
        // else ... (plus use this in create bill alert, too)
        /*[appointment setAttended:@YES];
         
         NSError *error = nil;
         if (![self.managedObjectContext save:&error]) {
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         }*/
        
    } else {
        
        // If appointment is still scheduled, prompt to cancel appointment
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [outputDateFormatter setDateFormat:@"eeee d MMM yyyy 'at' h:mm a"];
        NSString *dateTimeString = [outputDateFormatter stringFromDate:appointment.dateTime];
        NSString *alertMessage = [NSString stringWithFormat:@"This appointment is scheduled for %@. Do you wish to cancel the appointment?", dateTimeString];
        
        // Create alert controller
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scheduled Appointment"
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Position alert popover
        AppointmentCell *appointmentCell = (AppointmentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        alertController.popoverPresentationController.sourceView = appointmentCell;
        CGRect popoverRect = CGRectMake(appointmentCell.frame.size.width / 2,
                                        0,
                                        0,
                                        appointmentCell.frame.size.height);
        alertController.popoverPresentationController.sourceRect = popoverRect;
        alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
        
        UIAlertAction *cancelAppointmentAction = [UIAlertAction actionWithTitle:@"Cancel Appointment" style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                        // Delete appointment calendar event
                                                                        NSString *appointmentEventId = appointment.eventId;
                                                                        if (appointmentEventId != nil) {
                                                                            
                                                                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                                            EKEvent *appointmentEvent = [appDelegate.eventStore eventWithIdentifier:appointmentEventId];
                                                                            
                                                                            if (appointmentEvent != nil) {
                                                                                NSError *error;
                                                                                [appDelegate.eventStore removeEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&error];
                                                                            }
                                                                        }
                                                                        
                                                                        // Delete appointment
                                                                        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                                                                        
                                                                        NSError *error = nil;
                                                                        if (![self.managedObjectContext save:&error]) {
                                                                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                                            abort();
                                                                        }
                                                                    }];
        [alertController addAction:cancelAppointmentAction];
        
        UIAlertAction *leaveAppointmentAction = [UIAlertAction actionWithTitle:@"Leave Scheduled" style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                                
                                                                                [appointmentCell setCellTickButtonSelectedState:NO];
                                                                            }];
        [alertController addAction:leaveAppointmentAction];
        
        // Handle dismissing popever by tapping outside
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [appointmentCell setCellTickButtonSelectedState:NO];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)requestBillForAppointment:(Appointment *)appointment atIndexPath:(NSIndexPath *)indexPath withTickButton:(UIButton *)tickButton {
    
    // Prompt to create bill
    NSString *alertMessage = @"The payment method for this appointment indicates that you pay per appointment or per course of treatment. If you know the cost of your treatment, you can can create a bill now. If you do not yet know the cost, or you wish to create a bill later, you can do so in Treatment History.";
    
    // Create alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create Bill"
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Position alert popover
    AppointmentCell *appointmentCell = (AppointmentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    alertController.popoverPresentationController.sourceView = appointmentCell;
    CGRect popoverRect = CGRectMake(appointmentCell.frame.size.width / 2,
                                    0,
                                    0,
                                    appointmentCell.frame.size.height);
    alertController.popoverPresentationController.sourceRect = popoverRect;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    
    UIAlertAction *createBillNowAction = [UIAlertAction actionWithTitle:@"Create Bill Now" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                        // Create bill
                                                                        [self performSegueWithIdentifier:@"ShowBillView" sender:nil];
                                                                        
                                                                    }];
    [alertController addAction:createBillNowAction];
    
    UIAlertAction *createBillLaterAction = [UIAlertAction actionWithTitle:@"Create Bill Later" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       
                                                                       // Mark appointment complete
                                                                       [appointment setAttended:@YES];
                                                                       
                                                                       NSError *error = nil;
                                                                       if (![self.managedObjectContext save:&error]) {
                                                                           NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                                           abort();
                                                                       }
                                                                       
                                                                   }];
    [alertController addAction:createBillLaterAction];
    
    // Handle dismissing popever by tapping outside
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel appointment completion
        [appointmentCell setCellTickButtonSelectedState:NO];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return [[self fetchedResultsController] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return [[self fetchedResultsController] sectionForSectionIndexTitle:title atIndex:index];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        // Delete appointment calendar event
        Appointment *appointment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *appointmentEventId = appointment.eventId;
        if (appointmentEventId != nil) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            EKEvent *appointmentEvent = [appDelegate.eventStore eventWithIdentifier:appointmentEventId];
            
            if (appointmentEvent != nil) {
                NSError *error;
                [appDelegate.eventStore removeEvent:appointmentEvent span:EKSpanThisEvent commit:YES error:&error];
            }
        }
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit", @"Edit");
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    NSPredicate *attendedPredicate = [NSPredicate predicateWithFormat:@"attended = %@",[NSNumber numberWithBool: NO]];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(AppointmentCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowEditAppointmentView"]) {
        
        AddAppointmentViewController *controller = (AddAppointmentViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.navigationItem.title = NSLocalizedString(@"Edit Appointment", @"Edit Appointment");
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
        
        // Set appointment to be edited
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedAppointment = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        controller.editingAppointment = self.selectedAppointment;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowAddAppointmentView"]) {
    
        AddAppointmentViewController *controller = (AddAppointmentViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.navigationItem.title = NSLocalizedString(@"Add Appointment", @"Add Appointment");
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowBillView"]) {
    
        BillViewController *billViewController = (BillViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        billViewController.navigationItem.title = NSLocalizedString(@"Create Bill", @"Create Bill");
        billViewController.managedObjectContext = self.managedObjectContext;
        billViewController.delegate = self;
    }
}

#pragma mark - Add appointment delegate
- (void)addAppointmentViewControllerDidCancel:(AddAppointmentViewController *)controller {
    
    if (controller.editingAppointment) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAppointmentViewControllerDidFinish:(AddAppointmentViewController *)controller {
    
    if (controller.editingAppointment) {
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Bill delegate
- (void)billViewControllerDidCancel {
    
    
}

- (void)billViewControllerDidFinishWithBill:(Bill *)bill {
    
    
}

@end