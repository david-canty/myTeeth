//
//  ChargeType.h
//  myTeeth
//
//  Created by David Canty on 09/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, PaymentMethod, PaymentType, ServiceProvider;

@interface ChargeType : NSManagedObject

@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *appointments;
@property (nonatomic, retain) PaymentMethod *paymentMethod;
@property (nonatomic, retain) PaymentType *paymentType;
@property (nonatomic, retain) ServiceProvider *serviceProvider;
@end

@interface ChargeType (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
