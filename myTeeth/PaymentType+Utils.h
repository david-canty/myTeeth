//
//  PaymentType+Utils.h
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "PaymentType.h"

@interface PaymentType (Utils)

+ (NSUInteger)numberOfPaymentTypes;
+ (void)loadPaymentTypes;

@end