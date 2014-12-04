//
//  ChargeTypeDetailViewController_iPad.h
//  myTeeth
//
//  Created by David Canty on 28/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChargeTypeDetailViewControllerDelegate;

@interface ChargeTypeDetailViewController_iPad : UIViewController

@property (weak, nonatomic) id <ChargeTypeDetailViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *navigationItemTitleString;
@property (assign, nonatomic) BOOL isEditing;

@end

@protocol ChargeTypeDetailViewControllerDelegate <NSObject>
- (void)chargeTypeDetailViewControllerDidFinish:(ChargeTypeDetailViewController_iPad *)controller;
@end