//
//  Patient.h
//  myTeeth
//
//  Created by David Canty on 27/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, DentalPractice, Note, Tooth;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSNumber * addAppointmentEvents;
@property (nonatomic, retain) NSNumber * addCheckupEvents;
@property (nonatomic, retain) NSNumber * appointmentAlert;
@property (nonatomic, retain) NSString * calendarId;
@property (nonatomic, retain) NSString * calendarTitle;
@property (nonatomic, retain) NSNumber * checkupAlert;
@property (nonatomic, retain) NSNumber * checkupInterval;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * otherNames;
@property (nonatomic, retain) NSString * patientTitle;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * checkupEventId;
@property (nonatomic, retain) NSSet *appointments;
@property (nonatomic, retain) DentalPractice *dentalPractice;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSOrderedSet *teeth;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)insertObject:(Tooth *)value inTeethAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeethAtIndex:(NSUInteger)idx;
- (void)insertTeeth:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeethAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeethAtIndex:(NSUInteger)idx withObject:(Tooth *)value;
- (void)replaceTeethAtIndexes:(NSIndexSet *)indexes withTeeth:(NSArray *)values;
- (void)addTeethObject:(Tooth *)value;
- (void)removeTeethObject:(Tooth *)value;
- (void)addTeeth:(NSOrderedSet *)values;
- (void)removeTeeth:(NSOrderedSet *)values;
@end
