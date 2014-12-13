//
//  Appointment.m
//  myTeeth
//
//  Created by David Canty on 13/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Appointment.h"
#import "Bill.h"
#import "ChargeType.h"
#import "Note.h"
#import "Patient.h"
#import "TeamMember.h"
#import "TreatmentCourse.h"
#import "TreatmentItem.h"


@implementation Appointment

@dynamic attended;
@dynamic dateTime;
@dynamic duration;
@dynamic eventId;
@dynamic uniqueId;
@dynamic bill;
@dynamic chargeType;
@dynamic course;
@dynamic note;
@dynamic patient;
@dynamic teamMember;
@dynamic treatmentItems;

@end
