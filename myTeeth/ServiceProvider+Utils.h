//
//  ServiceProvider+Utils.h
//  myTeeth
//
//  Created by David Canty on 27/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ServiceProvider.h"

@interface ServiceProvider (Utils)

+ (NSUInteger)numberOfServiceProviders;
+ (void)loadServiceProviders;
+ (ServiceProvider *)serviceProviderWithName:(NSString *)name;
+ (ServiceProvider *)serviceProviderWithUniqueId:(NSString *)uniqueId;

@end