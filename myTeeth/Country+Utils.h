//
//  Country+Utils.h
//  myTeeth
//
//  Created by David Canty on 20/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Country.h"

@interface Country (Utils)

+ (NSUInteger)numberOfCountries;
+ (Country *)countryWithLocale:(NSString *)countryLocale;

@end