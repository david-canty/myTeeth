//
//  ChargeType+Utils.h
//  myTeeth
//
//  Created by David Canty on 27/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeType.h"

@interface ChargeType (Utils)

+ (NSUInteger)numberOfChargeTypes;
+ (void)loadChargeTypes;
+ (ChargeType *)chargeTypeWithName:(NSString *)name;

@end