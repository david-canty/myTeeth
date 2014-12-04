//
//  Salutation+Utils.h
//  myTeeth
//
//  Created by David Canty on 09/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Salutation.h"

@interface Salutation (Utils)

+ (NSUInteger)numberOfSalutations;
+ (void)loadSalutations;
+ (Salutation *)salutationWithName:(NSString *)name;

@end