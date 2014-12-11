//
//  ChargeType.m
//  myTeeth
//
//  Created by David Canty on 11/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeType.h"
#import "Appointment.h"
#import "PaymentMethod.h"
#import "PaymentType.h"
#import "ServiceProvider.h"


@implementation ChargeType

@dynamic typeName;
@dynamic uniqueId;
@dynamic regularAmount;
@dynamic appointments;
@dynamic paymentMethod;
@dynamic paymentType;
@dynamic serviceProvider;

@end
