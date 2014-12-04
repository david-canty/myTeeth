//
//  Salutation.h
//  myTeeth
//
//  Created by David Canty on 09/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Salutation : NSManagedObject

@property (nonatomic, retain) NSString * salutation;
@property (nonatomic, retain) NSString * uniqueId;

@end
