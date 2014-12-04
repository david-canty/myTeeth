//
//  JobTitle+Utils.h
//  myTeeth
//
//  Created by David Canty on 09/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "JobTitle.h"

@interface JobTitle (Utils)

+ (NSUInteger)numberOfJobTitles;
+ (void)loadJobTitles;
+ (JobTitle *)jobTitleWithName:(NSString *)name;

@end