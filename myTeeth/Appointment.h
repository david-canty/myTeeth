//
//  Appointment.h
//  myTeeth
//
//  Created by David Canty on 09/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bill, ChargeType, Note, Patient, TeamMember, TreatmentCourse, TreatmentItem;

@interface Appointment : NSManagedObject

@property (nonatomic, retain) NSNumber * attended;
@property (nonatomic, retain) NSDate * dateTime;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) Bill *bill;
@property (nonatomic, retain) TreatmentCourse *course;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) TeamMember *teamMember;
@property (nonatomic, retain) NSSet *treatmentItems;
@property (nonatomic, retain) ChargeType *chargeType;
@end

@interface Appointment (CoreDataGeneratedAccessors)

- (void)addTreatmentItemsObject:(TreatmentItem *)value;
- (void)removeTreatmentItemsObject:(TreatmentItem *)value;
- (void)addTreatmentItems:(NSSet *)values;
- (void)removeTreatmentItems:(NSSet *)values;

@end
