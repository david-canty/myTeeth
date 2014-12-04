//
//  MultipleSelectionListViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 09/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "MultipleSelectionListViewController.h"

static NSString *kMultipleSelectionListCellIdentifier = @"MultipleSelectionListCellIdentifier";

@interface MultipleSelectionListViewController ()

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSArray *selectionListItemsInSections;

- (IBAction)done:(id)sender;

@end

@implementation MultipleSelectionListViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    _sectionHeaders = @[];
    _selectionListItems = @[];
    _selectedItems = [@[] mutableCopy];
    self.tableView.allowsMultipleSelection = YES;
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
    
    // ask delegate for selection list items
    self.selectionListItems = [self.delegate getSelectionListItems];
    
    // set up table section headers
    NSMutableArray *sectionHeaders = [@[] mutableCopy];
    for (NSDictionary *selectionListItem in self.selectionListItems) {
        
        if (![sectionHeaders containsObject:selectionListItem[@"sectionHeader"]]) {
            [sectionHeaders addObject:selectionListItem[@"sectionHeader"]];
        }
    }
    self.sectionHeaders = sectionHeaders;
    
    // set up table section rows
    NSMutableArray *sectionsArray = [@[] mutableCopy];
    NSInteger sectionIndex = 0;
    for (NSString *sectionHeader in sectionHeaders) {
        
        NSInteger rowIndex = 0;
        NSMutableArray *sectionRowsArray = [@[] mutableCopy];
        for (NSDictionary *selectionListItem in self.selectionListItems) {
            
            if ([selectionListItem[@"sectionHeader"] isEqualToString:sectionHeader]) {
                
                sectionRowsArray[rowIndex] = selectionListItem;
                ++rowIndex;
            }
        }
        
        sectionsArray[sectionIndex] = sectionRowsArray;
        ++sectionIndex;
    }
    
    self.selectionListItemsInSections = sectionsArray;
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.selectionListItemsInSections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMultipleSelectionListCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *selectionListItem = self.selectionListItemsInSections[indexPath.section][indexPath.row];
    cell.textLabel.text = selectionListItem[@"displayName"];
    
    if ([self.selectedItems containsObject:selectionListItem]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *selectedItem = self.selectionListItemsInSections[indexPath.section][indexPath.row];
    if ([self.selectedItems containsObject:selectedItem]){
        [self.selectedItems removeObject:selectedItem];
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectedItems addObject:selectedItem];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)done:(id)sender {
    
    [[self delegate] multipleSelectionListViewControllerDidFinish:self withSelectedItems:(NSArray *)self.selectedItems];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
