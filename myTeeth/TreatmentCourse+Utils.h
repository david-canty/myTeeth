//
//  TreatmentCourse+Utils.h
//  myTeeth
//
//  Created by David Canty on 02/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "TreatmentCourse.h"

@interface TreatmentCourse (Utils)

+ (NSUInteger)numberOfTreatmentCourses;
+ (TreatmentCourse *)treatmentCourseWithUniqueId:(NSString *)uniqueId;

@end