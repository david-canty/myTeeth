//
//  TreatmentCourse.h
//  myTeeth
//
//  Created by David Canty on 01/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface TreatmentCourse : NSManagedObject

@property (nonatomic, retain) NSString * courseName;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface TreatmentCourse (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
