//
//  TreatmentCourse.h
//  myTeeth
//
//  Created by David Canty on 18/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface TreatmentCourse : NSManagedObject

@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface TreatmentCourse (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
