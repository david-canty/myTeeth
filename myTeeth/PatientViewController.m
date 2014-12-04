//
//  PatientViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 10/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "PatientViewController.h"
#import "DetailViewController.h"
#import "AddPatientViewController.h"
#import "Patient+Utils.h"
#import "Tooth+Utils.h"

static NSString *patientTableCellIdentifier = @"PatientTableCellIdentifier";

@interface PatientViewController () <NSFetchedResultsControllerDelegate, AddPatientViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) Patient *selectedPatient;

@end

@implementation PatientViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.clearsSelectionOnViewWillAppear = NO;
    
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
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPatient)];
    NSArray *myToolbarItems = @[addButton];
    [self setToolbarItems:myToolbarItems];
    UINavigationController *masterNavigationController = self.splitViewController.viewControllers[0];
    [masterNavigationController setToolbarHidden:NO animated:YES];
    
    if ([Patient numberOfPatients] == 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    UINavigationController *masterNavigationController = self.splitViewController.viewControllers[0];
    [masterNavigationController setToolbarHidden:YES animated:YES];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (void)addPatient {
    
    [self performSegueWithIdentifier:@"ShowAddPatientView" sender:self];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:patientTableCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
//    return [sectionInfo name];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[sectionInfo name]];
    NSDictionary *titleLabelAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]};
    [attributedString setAttributes:titleLabelAttributes range:NSMakeRange(0, attributedString.length)];
    
    UILabel *sectionTitleLabel = [[UILabel alloc] init];
    sectionTitleLabel.frame = CGRectMake(15, 8, 320, 20);
    sectionTitleLabel.attributedText = attributedString;
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:sectionTitleLabel];
    
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return [[self fetchedResultsController] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return [[self fetchedResultsController] sectionForSectionIndexTitle:title atIndex:index];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPatient = (Patient *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    // Store select patient's object id in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[self.selectedPatient.objectID URIRepresentation]
              forKey:@"selectedPatientObjectId"];
    [defaults synchronize];
    
    [self.detailViewController loadSelectedPatient];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // Show edit patient view
    self.selectedPatient = (Patient *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowEditPatientView" sender:nil];
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = @[lastNameSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"lastName" cacheName:@"Master"];
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
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
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
            
            // If no patients, remove selected patient object id from user defaults
            if ([Patient numberOfPatients] == 0) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:@"selectedPatientObjectId"];
                [defaults synchronize];
                
                [self.detailViewController deselectPatient];
                
                self.navigationItem.rightBarButtonItem.enabled = NO;
                [self setEditing:NO];
                
            } else {
                
                // check if visible patient has been deleted
                if (![Patient patientExistsWithUniqueId:self.detailViewController.patient.uniqueId]) {
                    
                    [self.detailViewController deselectPatient];
                }
                
                // If only one patient remains, store the object id in user defaults
                if ([Patient numberOfPatients] == 1) {
                    
                    NSUInteger patientIndex[] = {0, 0};
                    NSIndexPath *patientIndexPath = [[NSIndexPath alloc] initWithIndexes:patientIndex length:2];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    Patient *firstPatient = [self.fetchedResultsController objectAtIndexPath:patientIndexPath];
                    [defaults setURL:[firstPatient.objectID URIRepresentation]
                              forKey:@"selectedPatientObjectId"];
                    [defaults synchronize];
                    
                    [self.detailViewController disablePatientButton];
                }
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            
            [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [(Patient *)managedObject fullNameWithTitle];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowAddPatientView"]) {
        
        AddPatientViewController *addController = (AddPatientViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        addController.navigationItem.title = NSLocalizedString(@"Add Patient", @"Add Patient");
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowEditPatientView"]) {
        
        AddPatientViewController *editController = (AddPatientViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        editController.navigationItem.title = NSLocalizedString(@"Edit Patient", @"Edit Patient");
        editController.editingPatient = self.selectedPatient;
        editController.managedObjectContext = self.managedObjectContext;
        editController.delegate = self;
    }
}

- (void)addPatientViewControllerDidFinishWithPatient:(Patient *)patient {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([Patient numberOfPatients] == 1) {
            
            [self.detailViewController refreshView];
            
        } else {
            
            [self.detailViewController enablePatientButton];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

@end