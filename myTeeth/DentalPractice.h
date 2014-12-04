//
//  DentalPractice.h
//  myTeeth
//
//  Created by David Canty on 20/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient, TeamMember;

@interface DentalPractice : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSSet *patients;
@property (nonatomic, retain) NSSet *teamMembers;
@end

@interface DentalPractice (CoreDataGeneratedAccessors)

- (void)addPatientsObject:(Patient *)value;
- (void)removePatientsObject:(Patient *)value;
- (void)addPatients:(NSSet *)values;
- (void)removePatients:(NSSet *)values;

- (void)addTeamMembersObject:(TeamMember *)value;
- (void)removeTeamMembersObject:(TeamMember *)value;
- (void)addTeamMembers:(NSSet *)values;
- (void)removeTeamMembers:(NSSet *)values;

@end
