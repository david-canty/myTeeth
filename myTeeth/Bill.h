//
//  Bill.h
//  myTeeth
//
//  Created by David Canty on 13/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, PaymentTransaction;

@interface Bill : NSManagedObject

@property (nonatomic, retain) NSNumber * amountPaid;
@property (nonatomic, retain) NSNumber * billAmount;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * isPaid;
@property (nonatomic, retain) Appointment *appointment;
@property (nonatomic, retain) NSSet *paymentTransactions;
@end

@interface Bill (CoreDataGeneratedAccessors)

- (void)addPaymentTransactionsObject:(PaymentTransaction *)value;
- (void)removePaymentTransactionsObject:(PaymentTransaction *)value;
- (void)addPaymentTransactions:(NSSet *)values;
- (void)removePaymentTransactions:(NSSet *)values;

@end
