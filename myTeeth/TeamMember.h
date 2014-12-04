//
//  TeamMember.h
//  myTeeth
//
//  Created by David Canty on 18/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, DentalPractice;

@interface TeamMember : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * otherNames;
@property (nonatomic, retain) NSString * teamMemberTitle;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *appointments;
@property (nonatomic, retain) DentalPractice *dentalPractice;
@end

@interface TeamMember (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
