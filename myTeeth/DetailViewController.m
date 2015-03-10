//
//  DetailViewController.m
//  myTeeth
//
//  Created by Dave on 08/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import "DetailViewController.h"
#import "Patient+Utils.h"
#import "Tooth+Utils.h"
#import "ToothCell.h"
#import "Constants.h"
#import "ToothDetailViewController.h"
#import "SingleSelectionPopoverContentViewController.h"

static NSUInteger const kUpperLeftStartIndex = 0;
static NSUInteger const kUpperRightStartIndex = 8;
static NSUInteger const kLowerLeftStartIndex = 16;
static NSUInteger const kLowerRightStartIndex = 24;

static NSUInteger const kNumberOfTeethPerSection = 8;

static NSString *upperTeethLabelText = @"Upper Teeth";
static NSString *lowerTeethLabelText = @"Lower Teeth";

typedef NS_ENUM(NSInteger, TeethTableSection) {
    TeethTableSectionUpperLeft,
    TeethTableSectionUpperRight,
    TeethTableSectionLowerLeft,
    TeethTableSectionLowerRight
};

@interface DetailViewController () <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SingleSelectionPopoverContentViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UINavigationItem *navigatiomItem;

@property (weak, nonatomic) IBOutlet UITableView *teethTableView;

@property (weak, nonatomic) IBOutlet UICollectionView *upperTeethCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *lowerTeethCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *upperTeethLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerTeethLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *patientButton;

@property (strong, nonatomic) NSArray *toothNames;
@property (strong, nonatomic) NSMutableArray *upperLeftTeeth;
@property (strong, nonatomic) NSMutableArray *upperRightTeeth;
@property (strong, nonatomic) NSMutableArray *lowerLeftTeeth;
@property (strong, nonatomic) NSMutableArray *lowerRightTeeth;

@property (strong, nonatomic) NSIndexPath *selectedTableRowIndexPath;

@property (strong, nonatomic) UICollectionView *selectedCollectionView;
@property (strong, nonatomic) NSIndexPath *selectedCollectionViewIndexPath;

@property (strong, nonatomic) SingleSelectionPopoverContentViewController *singleSelectionPopoverVC;

@property (strong, nonatomic) UIPopoverController *patientPopoverController;

@property (assign, nonatomic) BOOL isWobbling;

@end

@implementation DetailViewController

/*#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

    }    
}*/

- (void)awakeFromNib {

    [self initializeAttributes];
}

- (void)initializeAttributes {
    
    self.toothNames = @[];
    self.upperLeftTeeth = [@[] mutableCopy];
    self.upperRightTeeth = [@[] mutableCopy];
    self.lowerLeftTeeth = [@[] mutableCopy];
    self.lowerRightTeeth = [@[] mutableCopy];
    self.selectedTableRowIndexPath = nil;
    self.selectedCollectionView = nil;
    self.selectedCollectionViewIndexPath = nil;
    self.isWobbling = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadSelectedPatient];

    /*UIBarButtonItem *patientBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Patient" style:UIBarButtonItemStyleBordered target:self action:@selector(selectedPatientTapped)];
    self.navigationItem.rightBarButtonItems = @[patientBarButtonItem];*/
    self.navigatiomItem.title = NSLocalizedString(@"myTeeth", @"myTeeth");
}

- (void)loadSelectedPatient {
    
    // Get selected patient object id from user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *selectedPatientURL = [defaults URLForKey:@"selectedPatientObjectId"];
    if (selectedPatientURL != nil) {
        
        if (self.masterPopoverController != nil) {
            [self.masterPopoverController dismissPopoverAnimated:YES];
        }
        
        self.selectedPatientObjectId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:selectedPatientURL];
        
        [self fetchPatient];
        [self fetchTeeth];
        
        self.selectedPatientUniqueId = self.patient.uniqueId;
        
        // Prepend patient's first name to upper and lower teeth labels
        NSString *firstName = self.patient.firstName;
        if ([[firstName substringFromIndex:firstName.length - 1] isEqualToString:@"s"] ) {
            firstName = [NSString stringWithFormat:@"%@'",firstName];
            
        } else {
            firstName = [NSString stringWithFormat:@"%@'s",firstName];
        }
        self.upperTeethLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, upperTeethLabelText];
        self.lowerTeethLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lowerTeethLabelText];
        
        if ([Patient numberOfPatients] == 1) {
            
            [self disablePatientButton];

        } else {
            
            [self enablePatientButton];
        }
        
        [self showTeethLabels];
        [self reloadTeethContainers];
        
    } else {
        
        [self disablePatientButton];
        [self hideTeethLabels];
    }

}

- (void)deselectPatient {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"selectedPatientObjectId"];
    [defaults synchronize];
    
    self.selectedPatientObjectId = nil;
    
    [self disablePatientButton];
    [self hideTeethLabels];
    
    [self reloadTeethContainers];
}

- (void)enablePatientButton {
    [self.patientButton setEnabled:YES];
}

- (void)disablePatientButton {
    [self.patientButton setEnabled:NO];
}

- (void)showTeethLabels {
    [self.upperTeethLabel setHidden:NO];
    [self.lowerTeethLabel setHidden:NO];
}

- (void)hideTeethLabels {
    [self.upperTeethLabel setHidden:YES];
    [self.lowerTeethLabel setHidden:YES];
}

- (void)reloadTeethContainers {
    [self.teethTableView reloadData];
    [self.upperTeethCollectionView reloadData];
    [self.lowerTeethCollectionView reloadData];
    [self centerTeethCollectionViews];
}

- (void)refreshView {
    [self initializeAttributes];
    [self loadSelectedPatient];
}

- (void)fetchPatient {
    
    NSError *error;
    self.patient = (Patient *)[self.managedObjectContext existingObjectWithID:self.selectedPatientObjectId error:&error];

    if (self.patient == nil) {
        
        NSLog(@"Error fetching patient");
        
    }
}

- (void)fetchTeeth {
    
    NSOrderedSet *patientTeeth = [self.patient valueForKeyPath:@"teeth"];

    // upper left teeth
    NSIndexSet *upperLeftTeethIndexes = [NSIndexSet indexSetWithIndexesInRange:(NSRange){kUpperLeftStartIndex, kNumberOfTeethPerSection}];
    [patientTeeth enumerateObjectsAtIndexes:upperLeftTeethIndexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.upperLeftTeeth addObject:(Tooth *)obj];
        
    }];
    
    // upper right teeth
    NSIndexSet *upperRightTeethIndexes = [NSIndexSet indexSetWithIndexesInRange:(NSRange){kUpperRightStartIndex, kNumberOfTeethPerSection}];
    [patientTeeth enumerateObjectsAtIndexes:upperRightTeethIndexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.upperRightTeeth addObject:(Tooth *)obj];
        
    }];
    
    // lower left teeth
    NSIndexSet *lowerLeftTeethIndexes = [NSIndexSet indexSetWithIndexesInRange:(NSRange){kLowerLeftStartIndex, kNumberOfTeethPerSection}];
    [patientTeeth enumerateObjectsAtIndexes:lowerLeftTeethIndexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.lowerLeftTeeth addObject:(Tooth *)obj];
        
    }];
    
    // lower right teeth
    NSIndexSet *lowerRightTeethIndexs = [NSIndexSet indexSetWithIndexesInRange:(NSRange){kLowerRightStartIndex, kNumberOfTeethPerSection}];
    [patientTeeth enumerateObjectsAtIndexes:lowerRightTeethIndexs options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.lowerRightTeeth addObject:(Tooth *)obj];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (self.selectedPatientObjectId != nil) {
    
        [self.teethTableView deselectRowAtIndexPath:[self.teethTableView indexPathForSelectedRow] animated:YES];
        [self centerTeethCollectionViews];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.selectedPatientObjectId != nil) {
    
        [self centerTeethCollectionViews];
    }
}

- (void)centerTeethCollectionViews {
    
    CGFloat newUpperOffsetX = (self.upperTeethCollectionView.contentSize.width - self.upperTeethCollectionView.frame.size.width) / 2;
    [self.upperTeethCollectionView setContentOffset:CGPointMake(newUpperOffsetX, 0) animated:YES];
    
    CGFloat newLowerOffsetX = (self.lowerTeethCollectionView.contentSize.width - self.lowerTeethCollectionView.frame.size.width) / 2;
    [self.lowerTeethCollectionView setContentOffset:CGPointMake(newLowerOffsetX, 0) animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    
    //barButtonItem.title = NSLocalizedString(@"Reception", @"Reception");
    [barButtonItem setImage:[UIImage imageNamed:@"btn_reception"]];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"ShowToothDetailView"]) {
        
        // get table index path of cell with detail button
        NSIndexPath *detailButtonIndexPath = [self.teethTableView indexPathForCell:sender];
        UITableViewCell *toothTableCell = [self.teethTableView cellForRowAtIndexPath:detailButtonIndexPath];
        
        ToothDetailViewController *controller = (ToothDetailViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        controller.toothName = toothTableCell.textLabel.text;
        
    }
    
    if ([segue.identifier isEqualToString: @"ShowPatientPopover"]) {
        
        // select patient from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"Patient";
        self.singleSelectionPopoverVC.sortDescriptor = @"lastName";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.predicate = nil;
        self.singleSelectionPopoverVC.attributeForDisplay = @"fullNameWithTitle";
        self.singleSelectionPopoverVC.selectedObjectId = self.selectedPatientObjectId;
        self.singleSelectionPopoverVC.delegate = self;
        
        // store reference to popover for dismissal
        self.patientPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

- (void)singleSelectionPopoverContentViewControllerDidFinishWithObject:(NSManagedObject *)selectedObject {
    
    // store select patient's object id in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[selectedObject.objectID URIRepresentation]
              forKey:@"selectedPatientObjectId"];
    [defaults synchronize];
    
    [self loadSelectedPatient];
    
    // dismiss popover
    [self.patientPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - upper teeth and lower teeth collection views
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (self.selectedPatientObjectId != nil) {
        
        return 2;
    }
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.selectedPatientObjectId != nil) {
        
        return kNumberOfTeethPerSection;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ToothCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kToothContainerCellIdentifier forIndexPath:indexPath];
    
    Tooth *tooth;
    
    if ([collectionView.restorationIdentifier isEqualToString:kUpperTeethCollectionView]) {
        
        if (indexPath.section == 0) {
            tooth = self.upperLeftTeeth[indexPath.row];
        } else if (indexPath.section == 1) {
            tooth = self.upperRightTeeth[indexPath.row];
        }
        
    } else if ([collectionView.restorationIdentifier isEqualToString:kLowerTeethCollectionView]) {
        
        if (indexPath.section == 0) {
            tooth = self.lowerLeftTeeth[indexPath.row];
        } else if (indexPath.section == 1) {
            tooth = self.lowerRightTeeth[indexPath.row];
        }
    }
    
    cell.toothNameLabel.text = tooth.name;
    cell.toothImage.image = [UIImage imageNamed:tooth.frontImage];
    cell.toothReferenceLabel.text = tooth.reference;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.teethTableView deselectRowAtIndexPath:[self.teethTableView indexPathForSelectedRow] animated:YES];
    
    // get respective table index path
    self.selectedTableRowIndexPath = [self tableViewIndexPathForCollectionView:collectionView withIndexPath:indexPath];
    
    // nudge partially visible collection view cell on tap
    [self nudgeCollectionView:collectionView atIndexPath:indexPath];
    
    // if respective table row is visible, wobble label
    NSArray *visibleTableIndexes = [self.teethTableView indexPathsForVisibleRows];
    
    // first check if we need to nudge partly visible respective cell in table view
    UITableViewCell *toothCell = [self.teethTableView cellForRowAtIndexPath:self.selectedTableRowIndexPath];
    CGRect cellRect = toothCell.frame;
    cellRect = [self.teethTableView convertRect:cellRect toView:self.teethTableView.superview];
    BOOL completelyVisible = CGRectContainsRect(self.teethTableView.frame, cellRect);
    if (!completelyVisible) {

        [self nudgeTableView:self.teethTableView atIndexPath:self.selectedTableRowIndexPath];
        
    } else if ([visibleTableIndexes containsObject:self.selectedTableRowIndexPath]) {
        
        [self wobbleSelectedTableRow];
        
    } else {
        
        // else, scroll tableview to respective row
        [self.teethTableView scrollToRowAtIndexPath:self.selectedTableRowIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        // and wobble label
        [self wobbleSelectedTableRow];
        
    }
}

#pragma mark - nudge selected items
- (void)nudgeTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *toothCell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect cellRect = toothCell.frame;
    cellRect = [tableView convertRect:cellRect toView:tableView.superview];
    BOOL completelyVisible = CGRectContainsRect(tableView.frame, cellRect);
    if (!completelyVisible) {
        // see if partially visible cell is at top or bottom of table view
        if (cellRect.origin.y < tableView.frame.size.height / 2) {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)nudgeCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    cellRect = [collectionView convertRect:cellRect toView:collectionView.superview];
    BOOL completelyVisible = CGRectContainsRect(collectionView.frame, cellRect);
    if (!completelyVisible) {
        // see if partially visible cell is at left or right of collection view
        if (cellRect.origin.x < collectionView.frame.size.width / 2) {
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }
}

#pragma mark - wobble selected items
- (void)wobbleSelectedTableRow {
    
    if (!self.isWobbling) {
        UITableViewCell *cell = [self.teethTableView cellForRowAtIndexPath:self.selectedTableRowIndexPath];
        
        CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                          [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
        wobble.autoreverses = YES;
        wobble.repeatCount = 2.0f;
        wobble.duration = 0.10f;
        wobble.delegate = self;
        [cell.textLabel.layer addAnimation:wobble forKey:nil];
    }
}

- (void)wobbleSelectedCollectionViewCell {
    
    if (!self.isWobbling) {
        UICollectionViewCell *cell = [self.selectedCollectionView cellForItemAtIndexPath:self.selectedCollectionViewIndexPath];
        
        CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                          [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
        wobble.autoreverses = YES;
        wobble.repeatCount = 2.0f;
        wobble.duration = 0.10f;
        wobble.delegate = self;
        [cell.contentView.layer addAnimation:wobble forKey:nil];
    }
}


- (void)animationDidStart:(CAAnimation *)theAnimation {
    
    self.isWobbling = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (flag) {
        self.isWobbling = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // wobble selected table view row at end of scrolling
    if ([scrollView isKindOfClass:[UITableView class]]) {
        [self wobbleSelectedTableRow];
    }
    
    // wobble selected collection view cell at end of scrolling
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        [self wobbleSelectedCollectionViewCell];
    }
}

#pragma mark - collectionview / tableview index mapping

- (NSIndexPath *)tableViewIndexPathForCollectionView:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)cvIndexPath {
    
    NSUInteger tableSection = 0;
    NSUInteger tableRow = 0;
    
    if ([collectionView.restorationIdentifier isEqualToString:kUpperTeethCollectionView]) {
        
        if (cvIndexPath.section == 0) {
            tableSection = cvIndexPath.section;
            tableRow = cvIndexPath.row;
        } else if (cvIndexPath.section == 1) {
            tableSection = cvIndexPath.section;
            tableRow = cvIndexPath.row;
        }
        
    } else if ([collectionView.restorationIdentifier isEqualToString:kLowerTeethCollectionView]) {
        
        if (cvIndexPath.section == 0) {
            tableSection = cvIndexPath.section + 2;
            tableRow = cvIndexPath.row;
        } else if (cvIndexPath.section == 1) {
            tableSection = cvIndexPath.section + 2;
            tableRow = cvIndexPath.row;
        }
    }

    return [NSIndexPath indexPathForRow:tableRow inSection:tableSection];
}

- (NSDictionary *)collectionViewIndexPathForTableView:(UITableView *)tv withIndexPath:(NSIndexPath *)tvIndexPath {
    
    NSUInteger cvSection = 0;
    NSUInteger cvRow = 0;
    NSString *collectionViewRestorationIdentifier = @"";
    
    switch (tvIndexPath.section) {
        case TeethTableSectionUpperLeft: {
            collectionViewRestorationIdentifier = kUpperTeethCollectionView;
            cvSection = 0;
            cvRow = tvIndexPath.row;
            break;
        }
        case TeethTableSectionUpperRight: {
            collectionViewRestorationIdentifier = kUpperTeethCollectionView;
            cvSection = 1;
            cvRow = tvIndexPath.row;
            break;
        }
        case TeethTableSectionLowerLeft: {
            collectionViewRestorationIdentifier = kLowerTeethCollectionView;
            cvSection = 0;
            cvRow = tvIndexPath.row;
            break;
        }
        case TeethTableSectionLowerRight: {
            collectionViewRestorationIdentifier = kLowerTeethCollectionView;
            cvSection = 1;
            cvRow = tvIndexPath.row;
            break;
        }
    }
    
    return @{@"collectionViewIdentifier" : collectionViewRestorationIdentifier,
             @"collectionViewIndexPath" : [NSIndexPath indexPathForRow:cvRow inSection:cvSection]};
}

#pragma mark - teeth tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.selectedPatientObjectId != nil) {
        
        return 4;

    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.selectedPatientObjectId != nil) {
        
        return kNumberOfTeethPerSection;
        
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *headerTitle = @"";
    
    switch (section) {
        case TeethTableSectionUpperLeft: {
            headerTitle = NSLocalizedString(@"Upper Left", @"Upper Left");
            break;
        }
        case TeethTableSectionUpperRight: {
            headerTitle = NSLocalizedString(@"Upper Right", @"Upper Right");
            break;
        }
        case TeethTableSectionLowerLeft: {
            headerTitle = NSLocalizedString(@"Lower Left", @"Lower Left");
            break;
        }
        case TeethTableSectionLowerRight: {
            headerTitle = NSLocalizedString(@"Lower Right", @"Lower Right");
            break;
        }
    }
    
    return headerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToothTableCellIdentifier forIndexPath:indexPath];
    
    Tooth *tooth;
    
    switch (indexPath.section) {
        case TeethTableSectionUpperLeft: {
            tooth = self.upperLeftTeeth[indexPath.row];
            break;
        }
        case TeethTableSectionUpperRight: {
            tooth = self.upperRightTeeth[indexPath.row];
            break;
        }
        case TeethTableSectionLowerLeft: {
            tooth = self.lowerLeftTeeth[indexPath.row];
            break;
        }
        case TeethTableSectionLowerRight: {
            tooth = self.lowerRightTeeth[indexPath.row];
            break;
        }
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", tooth.name, tooth.reference];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.teethTableView deselectRowAtIndexPath:[self.teethTableView indexPathForSelectedRow] animated:YES];
    
    // get respective collection view index path
    NSDictionary *cvDictionary = [self collectionViewIndexPathForTableView:tableView withIndexPath:indexPath];
    NSString *collectionViewIdentifier = cvDictionary[@"collectionViewIdentifier"];
    self.selectedCollectionViewIndexPath = cvDictionary[@"collectionViewIndexPath"];
    
    // nudge partially visible table view cell on tap
    [self nudgeTableView:tableView atIndexPath:indexPath];
    
    // if respective collection view cell is visible, wobble it
    NSArray *visibleCollectionViewIndexes;
    if ([collectionViewIdentifier isEqualToString:kUpperTeethCollectionView]) {
        visibleCollectionViewIndexes = [self.upperTeethCollectionView indexPathsForVisibleItems];
        self.selectedCollectionView = self.upperTeethCollectionView;
    } else {
        visibleCollectionViewIndexes = [self.lowerTeethCollectionView indexPathsForVisibleItems];
        self.selectedCollectionView = self.lowerTeethCollectionView;
    }
    
    // first check if we need to nudge partly visible respective collection view cell
    UICollectionViewLayoutAttributes *attributes = [self.selectedCollectionView layoutAttributesForItemAtIndexPath:self.selectedCollectionViewIndexPath];
    CGRect cellRect = attributes.frame;
    cellRect = [self.selectedCollectionView convertRect:cellRect toView:self.selectedCollectionView.superview];
    BOOL completelyVisible = CGRectContainsRect(self.selectedCollectionView.frame, cellRect);
    
    if (!completelyVisible) {
        
        [self nudgeCollectionView:self.selectedCollectionView atIndexPath:self.selectedCollectionViewIndexPath];
        
    } else if ([visibleCollectionViewIndexes containsObject:self.selectedCollectionViewIndexPath]) {
        
        [self wobbleSelectedCollectionViewCell];
        
    } else {
        
        // else, scroll collection view to respective cell
        [self.selectedCollectionView scrollToItemAtIndexPath:self.selectedCollectionViewIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        // and wobble cell
        [self wobbleSelectedCollectionViewCell];
    }
}

@end
