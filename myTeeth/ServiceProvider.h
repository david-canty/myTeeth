//
//  ServiceProvider.h
//  myTeeth
//
//  Created by David Canty on 09/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChargeType;

@interface ServiceProvider : NSManagedObject

@property (nonatomic, retain) NSString * providerName;
@property (nonatomic, retain) NSString * providerDescription;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *chargeType;
@end

@interface ServiceProvider (CoreDataGeneratedAccessors)

- (void)addChargeTypeObject:(ChargeType *)value;
- (void)removeChargeTypeObject:(ChargeType *)value;
- (void)addChargeType:(NSSet *)values;
- (void)removeChargeType:(NSSet *)values;

@end
