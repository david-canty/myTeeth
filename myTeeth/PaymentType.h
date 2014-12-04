//
//  PaymentType.h
//  myTeeth
//
//  Created by David Canty on 09/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface PaymentType : NSManagedObject

@property (nonatomic, retain) NSString * paymentType;
@property (nonatomic, retain) NSString * paymentTypeDescription;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * filtered;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface PaymentType (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
