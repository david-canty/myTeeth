//
//  ChargeType+Utils.h
//  myTeeth
//
//  Created by David Canty on 09/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeType.h"

@interface ChargeType (Utils)

+ (NSUInteger)numberOfChargeTypes;
+ (ChargeType *)chargeTypeWithUniqueId:(NSString *)uniqueId;

@end