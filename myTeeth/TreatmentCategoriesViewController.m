//
//  TreatmentCategoriesViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 10/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "TreatmentCategoriesViewController.h"
#import "TreatmentCategory+Utils.h"
#import "TreatmentItem+Utils.h"
#import "AddTreatmentCategoryViewController.h"
#import "Constants.h"

static NSString *treatmentCategoryTableCellIdentifier = @"TreatmentCategoryTableCellIdentifier";

@interface TreatmentCategoriesViewController () <AddTreatmentCategoryViewControllerDelegate>

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation TreatmentCategoriesViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;
    
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
    
    // load default treatment categories if not already loaded
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"xDefaultTreatmentCategoriesInitialized"] == nil) {
        
        [TreatmentCategory loadDefaultTreatmentCategories];
    }
    
    // load default treatment items if not already loaded
    if ([defaults stringForKey:@"xDefaultTreatmentItemsInitialized"] == nil) {
        
       [TreatmentItem loadDefaultTreatmentItems];
    }
    
    [activityIndicator stopAnimating];
    activityIndicator = nil;
    activityItem = nil;
    app.networkActivityIndicatorVisible = NO;
    
}

-(BOOL)shouldShowEdit {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:category];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ((result != nil) && ([result count] > numberOfDefaultTreatmentCategories) && (error == nil)) {
        return YES;
    } else {
        return NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTreatmentCategory)];
    NSArray *myToolbarItems = @[addButton];
    [self setToolbarItems: myToolbarItems];
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:NO animated:YES];
    [self.tableView reloadData];
    if (self.shouldShowEdit) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:YES animated:YES];
    //[self.detailViewController.navigationItem setRightBarButtonItems:nil animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)addTreatmentCategory {
    [self performSegueWithIdentifier:@"ShowAddTreatmentCategoryView" sender:self];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:treatmentCategoryTableCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    // disable cell interaction if default category
    TreatmentCategory *treatmentCategory = (TreatmentCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
    NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
    NSArray *defaultTreatmentItemsDictKeys = [defaultTreatmentItemsDict allKeys];
    BOOL canEditCateogry = YES;
    NSInteger loopCounter = 0;
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    while (canEditCateogry && loopCounter < [defaultTreatmentItemsDictKeys count]) {
        if ([treatmentCategory.categoryName isEqualToString:[defaultTreatmentItemsDictKeys objectAtIndex:loopCounter]]) {
            canEditCateogry = NO;
        }
        loopCounter ++;
    }
    if (!canEditCateogry) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.font = [UIFont italicSystemFontOfSize:16];
    } else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    return cell;
    
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo name];
}*/

/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return [[self fetchedResultsController] sectionIndexTitles];
 }
 */

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self fetchedResultsController] sectionForSectionIndexTitle:title atIndex:index];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    TreatmentCategory *treatmentCategory = (TreatmentCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
    NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
    NSArray *defaultTreatmentItemsDictKeys = [defaultTreatmentItemsDict allKeys];
    BOOL canEditCateogry = YES;
    NSInteger loopCounter = 0;
    while (canEditCateogry && loopCounter < [defaultTreatmentItemsDictKeys count]) {
        if ([treatmentCategory.categoryName isEqualToString:[defaultTreatmentItemsDictKeys objectAtIndex:loopCounter]]) {
            canEditCateogry = NO;
        }
        loopCounter ++;
    }
    return canEditCateogry;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        // reassign any treatment items to uncategorised
        NSMutableSet *categoryItems = (NSMutableSet *)[[self.fetchedResultsController objectAtIndexPath:indexPath] treatmentItems];
        if ([categoryItems count] > 0) {
            
            // get uncategorised treatment category
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
            [request setEntity:category];
            // retrive the objects with a given value for a certain property
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"categoryName == %@", uncategorisedTreatmentCategory];
            [request setPredicate:predicate];
            // Edit the sort key as appropriate.
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
            NSArray *sortDescriptors = @[sortDescriptor];
            [request setSortDescriptors:sortDescriptors];
            // Edit the section name key path and cache name if appropriate
            // nil for section name key path means "no sections"
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
            aFetchedResultsController.delegate = self;
            NSError *error = nil;
            NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&error];
            TreatmentCategory *uncategorisedCategory = (TreatmentCategory *)resultArray[0];
            
            // change treatment items' category to uncategorised
            if ((resultArray != nil) && ([resultArray count]) && (error == nil)) {
                NSMutableArray *treatmentItemsToRecategorise = [@[] mutableCopy];
                for (TreatmentItem *treatmentItem in categoryItems) {
                    [treatmentItemsToRecategorise addObject:treatmentItem];
                }
                for (TreatmentItem *treatmentItem in treatmentItemsToRecategorise) {
                    [treatmentItem setTreatmentCategory:uncategorisedCategory];
                }
            }
            
        }
        
        // delete category
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // save context
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.tableView reloadData];
        
        if (self.shouldShowEdit) {
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        } else {
            [self setEditing:NO animated:NO];
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 
 }
 */

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *categoryNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
    NSArray *sortDescriptors = @[categoryNameSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"categoryName" cacheName:@"Master"];
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
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [(TreatmentCategory *)managedObject categoryName];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    NSUInteger treatmentItemCount = [[(TreatmentCategory *)managedObject treatmentItems] count];
    if (treatmentItemCount == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu treatment item)", (unsigned long)treatmentItemCount];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu treatment items)", (unsigned long)treatmentItemCount];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowAddTreatmentCategoryView"]) {
        AddTreatmentCategoryViewController *addController = (AddTreatmentCategoryViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        addController.navigationItem.title = NSLocalizedString(@"Add Treatment Category", @"Add Treatment Category");
        addController.categoryIsBeingEdited = NO;
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"ShowEditTreatmentCategoryView"]) {
        AddTreatmentCategoryViewController *editController = (AddTreatmentCategoryViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedTreatmentCategory = (TreatmentCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        editController.navigationItem.title = NSLocalizedString(@"Edit Treatment Category", @"Edit Treatment Category");
        editController.categoryIsBeingEdited = YES;
        editController.editCategoryName = self.selectedTreatmentCategory.categoryName;
        editController.managedObjectContext = self.managedObjectContext;
        editController.delegate = self;
    }
}

- (void)addTreatmentCategoryViewControllerDidCancel:(AddTreatmentCategoryViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addTreatmentCategoryViewControllerDidFinish:(AddTreatmentCategoryViewController *)controller newCategoryName:(NSString *)newCategoryName {
    
    if (controller.categoryIsBeingEdited) {
        [self.selectedTreatmentCategory setCategoryName:newCategoryName];
    } else {
        TreatmentCategory *treatmentCategory = (TreatmentCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
        
        [treatmentCategory setCategoryName:newCategoryName];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [treatmentCategory setUniqueId:uuid];
    }

    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

@end