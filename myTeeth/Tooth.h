//
//  Tooth.h
//  myTeeth
//
//  Created by David Canty on 27/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Tooth : NSManagedObject

@property (nonatomic, retain) NSString * frontImage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * topImage;
@property (nonatomic, retain) Patient *patient;

@end
