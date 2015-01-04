//
//  BillViewController.h
//  myTeeth
//
//  Created by David Canty on 14/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bill;

@protocol BillViewControllerDelegate;

@interface BillViewController : UIViewController

@property (weak, nonatomic) id <BillViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@protocol BillViewControllerDelegate <NSObject>
- (void)billViewControllerDidCancel;
- (void)billViewControllerDidFinishWithBill:(Bill *)bill;
@end