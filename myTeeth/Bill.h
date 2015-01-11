//
//  Bill.h
//  myTeeth
//
//  Created by David Canty on 11/01/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, PaymentTransaction;

@interface Bill : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountPaid;
@property (nonatomic, retain) NSDecimalNumber * billAmount;
@property (nonatomic, retain) NSNumber * isPaid;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) Appointment *appointment;
@property (nonatomic, retain) NSSet *paymentTransactions;
@end

@interface Bill (CoreDataGeneratedAccessors)

- (void)addPaymentTransactionsObject:(PaymentTransaction *)value;
- (void)removePaymentTransactionsObject:(PaymentTransaction *)value;
- (void)addPaymentTransactions:(NSSet *)values;
- (void)removePaymentTransactions:(NSSet *)values;

@end
