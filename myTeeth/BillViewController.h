//
//  BillViewController.h
//  myTeeth
//
//  Created by David Canty on 14/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@protocol BillViewControllerDelegate;

@interface BillViewController : UIViewController

@property (weak, nonatomic) id <BillViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Bill *bill;

@end

@protocol BillViewControllerDelegate <NSObject>
- (void)billViewControllerDidCancel;
- (void)billViewControllerDidFinishWithBill:(Bill *)bill;
@end