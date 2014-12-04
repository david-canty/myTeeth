//
//  MultipleSelectionListViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 09/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultipleSelectionListViewControllerDelegate;

@interface MultipleSelectionListViewController : UITableViewController

@property (weak, nonatomic) id <MultipleSelectionListViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *selectionListItems;
@property (nonatomic, strong) NSMutableArray *selectedItems;

@end

@protocol MultipleSelectionListViewControllerDelegate <NSObject>

- (NSArray *)getSelectionListItems;
- (void)multipleSelectionListViewControllerDidFinish:(MultipleSelectionListViewController *)controller withSelectedItems:(NSArray *)selectedItems;

@end