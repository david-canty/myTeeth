//
//  Appointment.m
//  myTeeth
//
//  Created by David Canty on 26/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Appointment.h"
#import "Bill.h"
#import "ChargeType.h"
#import "Note.h"
#import "Patient.h"
#import "PaymentMethod.h"
#import "PaymentType.h"
#import "TeamMember.h"
#import "TreatmentCourse.h"
#import "TreatmentItem.h"


@implementation Appointment

@dynamic attended;
@dynamic dateTime;
@dynamic duration;
@dynamic uniqueId;
@dynamic eventId;
@dynamic bill;
@dynamic chargeType;
@dynamic course;
@dynamic note;
@dynamic patient;
@dynamic paymentMethod;
@dynamic paymentType;
@dynamic teamMember;
@dynamic treatmentItems;

@end
