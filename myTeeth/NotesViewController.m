//
//  NotesViewController.m
//  myTeeth
//
//  Created by Dave on 13/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteDetailViewControllerPad.h"
#import "Note.h"

@interface NotesViewController ()
@property (strong,nonatomic) NSIndexPath *selectedNoteIndexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation NotesViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addNote)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects:self.editButtonItem, flexibleSpace, composeButton, nil];
    self.navigationController.toolbarHidden = NO;
    self.noteDetailViewController = (NoteDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.navigationItem.title = NSLocalizedString(@"Notes", @"Notes");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNote {
    [self performSegueWithIdentifier:@"showNoteComposeView" sender:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    if (section == 0 &&
        [sectionInfo numberOfObjects] == 0) {
        self.editButtonItem.enabled = NO;
    } else {
        self.editButtonItem.enabled = YES;
    }
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCellIdentifier" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showNoteDetailViewController"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        UINavigationController *noteDetailNavVC = [segue destinationViewController];
        NoteDetailViewControllerPad *noteDetailVC = (NoteDetailViewControllerPad *)[noteDetailNavVC topViewController];
        noteDetailVC.noteTitleText = [object valueForKey:@"title"];
        noteDetailVC.noteText = [object valueForKey:@"note"];
        noteDetailVC.isFlagged = [[object valueForKey:@"flagged"] boolValue];
        noteDetailVC.delegate = self;

        _selectedNoteIndexPath = indexPath;
    }
    
    if ([[segue identifier] isEqualToString:@"showNoteComposeView"]) {
        
        self.selectedNoteIndexPath = nil;
            
        UINavigationController *noteDetailNavVC = [segue destinationViewController];
        NoteDetailViewControllerPad *noteDetailVC = (NoteDetailViewControllerPad *)[noteDetailNavVC topViewController];
        noteDetailVC.isAdding = YES;
        noteDetailVC.delegate = self;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Exclude appointment notes
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"appointment == %@", nil];
    [fetchRequest setPredicate:predicate];
    
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
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
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

// Note Detail View Controller Delegate

- (void)noteDetailViewControllerDelegateShoudDeleteNote:(NoteDetailViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:_selectedNoteIndexPath]];
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

- (void)noteDetailViewControllerDelegateShoudAddNote:(NoteDetailViewController *)controller {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    if (controller.isAdding) {
        
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newNote setValue:[NSDate date] forKey:@"created"];
        [newNote setValue:[NSDate date] forKey:@"modified"];
        [newNote setValue:controller.noteTitleTextField.text forKey:@"title"];
        [newNote setValue:controller.noteTextView.text forKey:@"note"];

    } else {
    
        Note *editedNote = [self.fetchedResultsController objectAtIndexPath:_selectedNoteIndexPath];
        [editedNote setValue:[NSDate date] forKey:@"modified"];
        [editedNote setValue:controller.noteTitleTextField.text forKey:@"title"];
        [editedNote setValue:controller.noteTextView.text forKey:@"note"];

    }
    
    // Save the context
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
     }
    
    // dismiss note detail view
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)noteDetailViewControllerDelegateShouldCancel {
    
    // dismiss note detail view
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

// field edit update methods
- (void)updateNoteTitle:(NSString *)noteTitle {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *noteObject = [self.fetchedResultsController objectAtIndexPath:_selectedNoteIndexPath];
    [noteObject setValue:noteTitle forKey:@"title"];
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"title updated");
    [self.tableView reloadData];
}

- (void)updateNoteNote:(NSString *)noteNote {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *noteObject = [self.fetchedResultsController objectAtIndexPath:_selectedNoteIndexPath];
    [noteObject setValue:noteNote forKey:@"note"];
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"note updated");
    [self.tableView reloadData];
}

- (void)updateNoteFlag:(BOOL)isFlagged {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *noteObject = [self.fetchedResultsController objectAtIndexPath:_selectedNoteIndexPath];
    [noteObject setValue:[NSNumber numberWithBool:isFlagged] forKey:@"flagged"];
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"title"];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
	[outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[outputDateFormatter setDateFormat:@"d MMMM yyyy, H:mm"];
    NSString *modifiedDateString = [NSString stringWithFormat:@"Modifed: %@",[outputDateFormatter stringFromDate:[object valueForKey:@"modified"]]];
    
    // set string attributes
    NSDictionary *modifedLabelAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0] };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:modifiedDateString];
    [attributedString setAttributes:modifedLabelAttributes range:NSMakeRange(0, 8)];
    cell.detailTextLabel.attributedText = attributedString;
    
    // show flagged indicator
    cell.imageView.image = ([(NSNumber *)[object valueForKey:@"flagged"] boolValue]) ? [UIImage imageNamed:@"blueDot"] : nil;
}

@end
