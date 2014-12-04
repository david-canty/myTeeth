//
//  Note.h
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment, Patient;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * flagged;
@property (nonatomic, retain) NSDate * modified;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) Appointment *appointment;
@property (nonatomic, retain) Patient *patient;

@end
