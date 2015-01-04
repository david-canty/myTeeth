//
//  SingleSelectionListViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 02/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleSelectionListViewControllerDelegate;

@interface SingleSelectionListViewController : UITableViewController

@property (weak, nonatomic) id <SingleSelectionListViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *selectionList;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property NSInteger initialSelection;
@property (nonatomic, strong) NSString *sectionHeader;
@property (nonatomic, strong) NSString *sectionFooter;
@property (nonatomic, assign) BOOL autoReturnAfterSelection;

- (IBAction)done:(id)sender;

@end

@protocol SingleSelectionListViewControllerDelegate <NSObject>

- (void)singleSelectionListViewControllerDidFinish:(SingleSelectionListViewController *)controller withSelectedItem:(NSDictionary *)selectedItem;

@end