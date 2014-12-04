//
//  TreatmentItem+Utils.h
//  myTeeth
//
//  Created by David Canty on 26/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "TreatmentItem.h"

@interface TreatmentItem (Utils)

+ (void)loadDefaultTreatmentItems;
+ (instancetype)treatmentItemWithUniqueID:(NSString *)uniqueId;

@end