//
//  DentalPractice+Utils.h
//  myTeeth
//
//  Created by David Canty on 20/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "DentalPractice.h"

@interface DentalPractice (Utils)

+ (NSString *)dentalPracticeContactId;
+ (NSString *)dentalPracticeName;
+ (void)setDentalPracticeContactId:(NSString *)contactId;
+ (void)setDentalPracticeName:(NSString *)practiceName;

@end