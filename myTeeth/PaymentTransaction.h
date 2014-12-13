//
//  PaymentTransaction.h
//  myTeeth
//
//  Created by David Canty on 13/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bill;

@interface PaymentTransaction : NSManagedObject

@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * transactionAmount;
@property (nonatomic, retain) NSDate * transactionDate;
@property (nonatomic, retain) Bill *bill;

@end
