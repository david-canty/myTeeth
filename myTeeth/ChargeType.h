//
//  ChargeType.h
//  myTeeth
//
//  Created by David Canty on 09/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface ChargeType : NSManagedObject

@property (nonatomic, retain) NSString * chargeType;
@property (nonatomic, retain) NSString * chargeTypeDescription;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface ChargeType (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
