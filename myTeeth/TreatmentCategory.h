//
//  TreatmentCategory.h
//  myTeeth
//
//  Created by David Canty on 18/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TreatmentItem;

@interface TreatmentCategory : NSManagedObject

@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSSet *treatmentItems;
@end

@interface TreatmentCategory (CoreDataGeneratedAccessors)

- (void)addTreatmentItemsObject:(TreatmentItem *)value;
- (void)removeTreatmentItemsObject:(TreatmentItem *)value;
- (void)addTreatmentItems:(NSSet *)values;
- (void)removeTreatmentItems:(NSSet *)values;

@end
