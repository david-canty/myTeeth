//
//  ChargeTypeViewController_iPad.h
//  myTeeth
//
//  Created by David Canty on 24/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChargeTypeViewControllerDelegate;

@class ChargeType, PaymentType, PaymentMethod;

@interface ChargeTypeViewController_iPad : UIViewController

@property (weak, nonatomic) id <ChargeTypeViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) ChargeType *selectedChargeType;
@property (strong, nonatomic) PaymentType *selectedPaymentType;
@property (strong, nonatomic) PaymentMethod *selectedPaymentMethod;

@property (assign, nonatomic) BOOL isEditing;

@end

@protocol ChargeTypeViewControllerDelegate <NSObject>
- (void)chargeTypeViewControllerDidFinishWithChargeType:(ChargeType *)selectedChargeType paymentType:(PaymentType *)selectedPaymentType paymentMethod:(PaymentMethod *)selectedPaymentMethod;
@end