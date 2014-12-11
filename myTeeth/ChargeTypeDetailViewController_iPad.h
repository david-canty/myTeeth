//
//  ChargeTypeDetailViewController_iPad.h
//  myTeeth
//
//  Created by David Canty on 28/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChargeType;

@protocol ChargeTypeDetailViewControllerDelegate;

@interface ChargeTypeDetailViewController_iPad : UIViewController

@property (weak, nonatomic) id <ChargeTypeDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ChargeType *editingChargeType;

@end

@protocol ChargeTypeDetailViewControllerDelegate <NSObject>
- (void)chargeTypeDetailViewControllerDidFinishWithChargeType:(ChargeType *)chargeType;
@end