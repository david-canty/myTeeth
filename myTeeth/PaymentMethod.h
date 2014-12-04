//
//  PaymentMethod.h
//  myTeeth
//
//  Created by David Canty on 09/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface PaymentMethod : NSManagedObject

@property (nonatomic, retain) NSString * paymentMethod;
@property (nonatomic, retain) NSString * paymentMethodDescription;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSNumber * filtered;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface PaymentMethod (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
