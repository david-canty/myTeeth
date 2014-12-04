//
//  Appointment+Utils.h
//  myTeeth
//
//  Created by David Canty on 23/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Appointment.h"

@interface Appointment (Utils)

+ (NSUInteger)numberOfAppointments;
+ (NSDate *)dateOfLastAppointment;

@end