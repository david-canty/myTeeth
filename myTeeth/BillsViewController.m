//
//  BillsViewController.m
//  myTeeth
//
//  Created by David Canty on 10/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "BillsViewController.h"
#import "BillsTableViewCell.h"
#import "Bill+Utils.h"
#import "Appointment+Utils.h"
#import "Patient+Utils.h"

static NSString *kBillsTableCellIdentifier = @"BillsTableCellIdentifier";
static NSString *kTableViewSectionHeaderViewIdentifier = @"TableViewSectionHeaderViewIdentifier";
static NSString *kTableViewSectionFooterViewIdentifier = @"TableViewSectionFooterViewIdentifier";

@interface BillsViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSLocale *defaultsLocale;
@property (strong, nonatomic) NSNumberFormatter *currencyNumberFormatter;

@end

@implementation BillsViewController

#pragma mark - View lifecycle
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addChargeType)];
//    NSArray *myToolbarItems = @[addButton];
//    [self setToolbarItems:myToolbarItems];
    
    // Get default locale from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.defaultsLocale = [NSLocale localeWithLocaleIdentifier:[defaults objectForKey:@"DefaultLocaleId"]];
    
    // Set up currency number formatter
    self.currencyNumberFormatter = [[NSNumberFormatter alloc] init];
    self.currencyNumberFormatter.locale = self.defaultsLocale;
    self.currencyNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyNumberFormatter.maximumFractionDigits = 2;
    self.currencyNumberFormatter.minimumFractionDigits = 2;
    self.currencyNumberFormatter.usesGroupingSeparator = YES;
    self.currencyNumberFormatter.lenient = YES;
    self.currencyNumberFormatter.generatesDecimalNumbers = YES;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kTableViewSectionHeaderViewIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kTableViewSectionFooterViewIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([Bill numberOfBills] == 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    BillsTableViewCell *cell = (BillsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kBillsTableCellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(BillsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Bill *bill = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Bill amount
    cell.amountLabel.text = [self.currencyNumberFormatter stringFromNumber:bill.billAmount];
    
    // Bill balance
    NSDecimalNumber *amountPaid = [bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
    NSDecimalNumber *balance = [bill.billAmount decimalNumberBySubtracting:amountPaid];
    cell.balanceLabel.text = [self.currencyNumberFormatter stringFromNumber:balance];
    
    // Bill appointment
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    outputDateFormatter.locale = [NSLocale currentLocale];
    [outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [outputDateFormatter setDateFormat:@"d MMM yyyy, h:mm a"];
    NSString *dateTimeString = [outputDateFormatter stringFromDate:bill.appointment.dateTime];
    cell.appointmentLabel.text = dateTimeString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *headerView;
    
    headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewSectionHeaderViewIdentifier];
    
    if (!headerView) {
        
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableViewSectionHeaderViewIdentifier];
        headerView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    
    headerView.textLabel.text = [sectionInfo name];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *footerView;
    
    footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewSectionFooterViewIdentifier];
    
    if (!footerView) {
        
        footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableViewSectionFooterViewIdentifier];
        footerView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    NSString *billCount = numberOfObjects == 1 ? [NSString stringWithFormat:@"%lu bill", numberOfObjects] : [NSString stringWithFormat:@"%lu bills", numberOfObjects];
    
    NSArray *sectionBills = [sectionInfo objects];
    NSDecimalNumber *billTotal = [NSDecimalNumber zero];
    for (Bill *bill in sectionBills) {
        
        billTotal = [billTotal decimalNumberByAdding:bill.billAmount];
    }
    
    NSString *billSummary = [NSString stringWithFormat:@"%@ (%@)", [self.currencyNumberFormatter stringFromNumber:billTotal], billCount];

    footerView.textLabel.text = billSummary;
    
    return footerView;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@""]) {
        
        
    }
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bill" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"billAmount" ascending:NO];
    NSArray *sortDescriptors = @[nameSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"appointment.patient.firstName" cacheName:nil];
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
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end