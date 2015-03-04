//
//  SingleSelectionListViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 02/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "SingleSelectionListViewController.h"

static NSString *kSelectionListCellIdentifier = @"SelectionListCellIdentifier";

@implementation SingleSelectionListViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    _initialSelection = -1;
    _selectionList = [@[] mutableCopy];
    self.autoReturnAfterSelection = NO;
}

- (void)didReceiveMemoryWarning {
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Check to see if user has indicated a row to be selected, and set it
    if (_initialSelection > -1 && _initialSelection < [_selectionList count])
    {
        NSUInteger newIndex[] = {0, _initialSelection};
        NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
        self.lastIndexPath = newPath;
    } 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return _sectionHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _sectionFooter;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_selectionList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectionListCellIdentifier forIndexPath:indexPath];
    
    NSUInteger row = [indexPath indexAtPosition:1];
    NSUInteger oldRow = [_lastIndexPath indexAtPosition:1];
    
    NSDictionary *selectionListItemDict = self.selectionList[row];
    
    if (selectionListItemDict[@"itemColor"]) {
        
        // If we have a color, we have a Calendar so add respectively colored • to beginning
        NSDictionary *modifedLabelAttributes = @{
                                                 NSForegroundColorAttributeName : selectionListItemDict[@"itemColor"],
                                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:36.0]};
        NSDictionary *labelBaselibeAttribute = @{
                                                 NSBaselineOffsetAttributeName : @7.0};
        NSString *itemString = [NSString stringWithFormat:@"• %@", selectionListItemDict[@"displayName"]];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:itemString];
        [attributedString setAttributes:modifedLabelAttributes range:NSMakeRange(0, 1)];
        [attributedString setAttributes:labelBaselibeAttribute range:NSMakeRange(1, attributedString.length-1)];
        cell.textLabel.attributedText = attributedString;
        
    } else {
    
        cell.textLabel.text = selectionListItemDict[@"displayName"];
    }
    
    cell.accessoryType = (row == oldRow && _lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger newRow = [indexPath indexAtPosition:1];
    NSInteger oldRow = [_lastIndexPath indexAtPosition:1];
    
    if (newRow != oldRow || _lastIndexPath == nil) {
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (_lastIndexPath != nil) {
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: _lastIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSUInteger newIndex[] = {0, newRow};
        _lastIndexPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    }
    
    if (self.autoReturnAfterSelection) {
        
        [self done:nil];
    }
}

- (IBAction)done:(id)sender {
    
    if (_lastIndexPath != nil) {
        [[self delegate] singleSelectionListViewControllerDidFinish:self withSelectedItem:[_selectionList objectAtIndex:[_lastIndexPath row]]];
    } else {
        [[self delegate] singleSelectionListViewControllerDidFinish:self withSelectedItem:@{@"displayName" : NSLocalizedString(@"Please Select", @"Please Select"), @"uniqueId" : @""}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end