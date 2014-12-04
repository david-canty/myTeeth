//
//  SingleSelectionPopoverContentViewController.m
//  myTeeth
//
//  Created by David Canty on 27/05/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "SingleSelectionPopoverContentViewController.h"

static NSString *kSelectionListPopoverCellIdentifier    = @"SelectionListPopoverCellIdentifier";
static float kPopoverTableRowHeight                     = 44.0;
static float kPopoverWidth                              = 360.0;

@interface SingleSelectionPopoverContentViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end

@implementation SingleSelectionPopoverContentViewController

- (void)awakeFromNib {

    [super awakeFromNib];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Check for pre-selected row
    __block NSInteger selectedObjectIndex = -1;
    NSArray *objectsArray = [[[self.fetchedResultsController sections] objectAtIndex:0] objects];
    [objectsArray enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
        if (obj.objectID == self.selectedObjectId) {
            selectedObjectIndex = (NSInteger)idx;
        }
    }];
    
    if (selectedObjectIndex > -1) {
        NSUInteger newIndex[] = {0, selectedObjectIndex};
        NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
        self.lastIndexPath = newPath;
    }
    
    // Set preferred content size depending on the number of table rows
    NSInteger tableRowCount = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    float tableHeight = kPopoverTableRowHeight;
    if (tableRowCount > 1 &&
        tableRowCount < 7) {
        
        // Set table height to number of rows if between 2 to 6
        tableHeight = tableHeight * tableRowCount;
        
    } else if (tableRowCount >= 7) {
        
        // Set maximum height of table to 6 rows
        tableHeight = tableHeight * 6;
    }
    [self setPreferredContentSize:CGSizeMake(kPopoverWidth, tableHeight)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
        
    } else {
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectionListPopoverCellIdentifier forIndexPath:indexPath];
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:self.attributeForDisplay];
    
    NSUInteger row = [indexPath indexAtPosition:1];
    NSUInteger oldRow = [self.lastIndexPath indexAtPosition:1];
    cell.accessoryType = (row == oldRow && self.lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger newRow = [indexPath indexAtPosition:1];
    NSInteger oldRow = [self.lastIndexPath indexAtPosition:1];
    
    if (newRow != oldRow || self.lastIndexPath == nil) {
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: self.lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        NSUInteger newIndex[] = {0, newRow};
        self.lastIndexPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[self delegate] singleSelectionPopoverContentViewControllerDidFinishWithObject:selectedObject];

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortDescriptor ascending:self.isSortDescriptorAscending];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    if (self.predicate != nil) {
        
        [fetchRequest setPredicate:self.predicate];
    }
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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

@end