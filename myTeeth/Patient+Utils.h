//
//  Patient+Utils.h
//  myTeeth
//
//  Created by David Canty on 10/05/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Patient.h"

@interface Patient (Utils)

+ (NSUInteger)numberOfPatients;
+ (BOOL)patientExistsWithObjectId:(NSManagedObjectID *)objId;
+ (BOOL)patientExistsWithUniqueId:(NSString *)uniqueId;
+ (Patient *)patientWithUniqueId:(NSString *)uniqueId;
+ (NSArray *)allPatients;

- (NSString *)fullNameWithTitle;

@end