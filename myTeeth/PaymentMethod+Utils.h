//
//  PaymentMethod+Utils.h
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "PaymentMethod.h"

@interface PaymentMethod (Utils)

+ (NSUInteger)numberOfPaymentMethods;
+ (void)loadPaymentMethods;
+ (PaymentMethod *)paymentMethodWithName:(NSString *)name;
+ (PaymentMethod *)paymentMethodWithUniqueId:(NSString *)uniqueId;

@end