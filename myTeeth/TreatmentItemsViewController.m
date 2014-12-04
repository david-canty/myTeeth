//
//  TreatmentItemsViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 10/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "TreatmentItemsViewController.h"
#import "TreatmentItem+Utils.h"
#import "TreatmentCategory+Utils.h"
#import "AddTreatmentItemViewController.h"
#import "Constants.h"

@interface TreatmentItemsViewController () <AddTreatmentItemViewControllerDelegate>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TreatmentItemsViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = activityItem;
    self.clearsSelectionOnViewWillAppear = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // load default treatment categories if not already loaded
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    app.networkActivityIndicatorVisible = NO;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

-(BOOL)shouldShowEdit {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentItem" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:category];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ((result != nil) && ([result count] > numberOfDefaultTreatmentItems) && (error == nil)) {
        return YES;
    } else {
        return NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTreatmentItem)];
    NSArray *myToolbarItems = @[addButton];
    [self setToolbarItems: myToolbarItems];
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:NO animated:YES];
    if (self.shouldShowEdit) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    UINavigationController *masterNavigationController = [self.splitViewController.viewControllers objectAtIndex:0];
    [masterNavigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)addTreatmentItem {
    [self performSegueWithIdentifier:@"ShowAddTreatmentItemView" sender:self];
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
    
    static NSString *treatmentItemTableCellIdentifier = @"TreatmentItemTableCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:treatmentItemTableCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    // disable cell interaction if default item
    BOOL canEditItem = YES;
    TreatmentItem *treatmentItem = (TreatmentItem *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
    NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
    NSArray *defaultTreatmentCategories = [defaultTreatmentItemsDict allKeys];
    NSInteger categoryLoopCounter = 0;
    while (canEditItem && (categoryLoopCounter < [defaultTreatmentCategories count])) {
        NSString *defaultCategory = [defaultTreatmentCategories objectAtIndex:categoryLoopCounter];
        NSArray *defaultCategoryTreatmentItems = defaultTreatmentItemsDict[defaultCategory];
        NSInteger itemLoopCounter = 0;
        while (canEditItem && itemLoopCounter < [defaultCategoryTreatmentItems count]) {
            if ([treatmentItem.itemName isEqualToString:[defaultCategoryTreatmentItems objectAtIndex:itemLoopCounter]]) {
                canEditItem = NO;
            }
            itemLoopCounter ++;
        }
        categoryLoopCounter ++;
    }

    if (!canEditItem) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.font = [UIFont italicSystemFontOfSize:14];
    } else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [NSString stringWithFormat:NSLocalizedString(@"%@",@"%@"), [sectionInfo name]];
}

/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self fetchedResultsController] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self fetchedResultsController] sectionForSectionIndexTitle:title atIndex:index];
}*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // disable edit if default item
    BOOL canEditItem = YES;
    TreatmentItem *treatmentItem = (TreatmentItem *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
    NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
    NSArray *defaultTreatmentCategories = [defaultTreatmentItemsDict allKeys];
    NSInteger categoryLoopCounter = 0;
    while (canEditItem && (categoryLoopCounter < [defaultTreatmentCategories count])) {
        NSString *defaultCategory = defaultTreatmentCategories[categoryLoopCounter];
        NSArray *defaultCategoryTreatmentItems = defaultTreatmentItemsDict[defaultCategory];
        NSInteger itemLoopCounter = 0;
        while (canEditItem && itemLoopCounter < [defaultCategoryTreatmentItems count]) {
            if ([treatmentItem.itemName isEqualToString:defaultCategoryTreatmentItems[itemLoopCounter]]) {
                canEditItem = NO;
            }
            itemLoopCounter ++;
        }
        categoryLoopCounter ++;
    }

    return canEditItem;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // delete item
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // save context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        // refresh fetchedresultscontroller
        error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        // reload table
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *sortDescriptors = nil;
    NSString *sectionNameKeyPath = nil;
    sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"treatmentCategory.categoryName" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"itemName" ascending:YES], nil];
    sectionNameKeyPath = @"treatmentCategory.categoryName";
    [fetchRequest setSortDescriptors:sortDescriptors];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:@"Master"];
    
    [fetchRequest setFetchBatchSize:20];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [(TreatmentItem *)managedObject itemName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowAddTreatmentItemView"]) {
        AddTreatmentItemViewController *addController = (AddTreatmentItemViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        addController.navigationItem.title = NSLocalizedString(@"Add Treatment Item", @"Add Treatment Item");
        addController.itemIsBeingEdited = NO;
        addController.managedObjectContext = self.managedObjectContext;
        addController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"ShowEditTreatmentItemView"]) {
        AddTreatmentItemViewController *editController = (AddTreatmentItemViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        self.selectedTreatmentItem = (TreatmentItem *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        editController.navigationItem.title = NSLocalizedString(@"Edit Treatment Item", @"Edit Treatment Item");
        editController.itemIsBeingEdited = YES;
        editController.editItemName = self.selectedTreatmentItem.itemName;
        editController.editItemOriginalName = self.selectedTreatmentItem.itemName;
        editController.editItemCategoryName = [self.selectedTreatmentItem.treatmentCategory categoryName];
        editController.editItemOriginalCategoryName = [self.selectedTreatmentItem.treatmentCategory categoryName];
        editController.managedObjectContext = self.managedObjectContext;
        editController.delegate = self;
    }
}

- (void)addTreatmentItemViewControllerDidCancel:(AddTreatmentItemViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addTreatmentItemViewControllerDidFinish:(AddTreatmentItemViewController *)controller newItemName:(NSString *)newItemName newItemCategoryName:(NSString *)newItemCategoryName {
    
    if (controller.itemIsBeingEdited) {
        // set treatment item name
        [self.selectedTreatmentItem setItemName:newItemName];
        // set treatment item category relationship
        TreatmentCategory *tg = [self getTreatmentCategoryObjectWithCategoryName:newItemCategoryName];
        [self.selectedTreatmentItem setTreatmentCategory:tg];
        
    } else {
        // create treatment item
        TreatmentItem *treatmentItem = (TreatmentItem *)[NSEntityDescription insertNewObjectForEntityForName:@"TreatmentItem" inManagedObjectContext:self.managedObjectContext];
        
        [treatmentItem setItemName:newItemName];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [treatmentItem setUniqueId:uuid];
        
        // add relationship between treatment item and treatment category
        TreatmentCategory *treatmentCategory = [self getTreatmentCategoryObjectWithCategoryName:newItemCategoryName];
        [treatmentItem setTreatmentCategory:treatmentCategory];
        
    }
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // refresh fetchedresultscontroller
    error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (TreatmentCategory *)getTreatmentCategoryObjectWithCategoryName:(NSString *)categoryName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:category];
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"categoryName == %@", categoryName];
    [request setPredicate:predicate];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    // Edit the section name key path and cache name if appropriate
    // nil for section name key path means "no sections"
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ((result != nil) && ([result count]) && (error == nil)) {
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:result];
        TreatmentCategory *treatmentCategory = (TreatmentCategory *)resultArray[0];
        return treatmentCategory;
    } else {
        return nil;
    }
}

@end