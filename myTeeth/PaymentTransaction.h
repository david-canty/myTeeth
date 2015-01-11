//
//  PaymentTransaction.h
//  myTeeth
//
//  Created by David Canty on 11/01/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bill;

@interface PaymentTransaction : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * transactionAmount;
@property (nonatomic, retain) NSDate * transactionDate;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) Bill *bill;

@end
