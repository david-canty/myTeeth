//
//  Country.h
//  myTeeth
//
//  Created by David Canty on 21/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Country : NSManagedObject

@property (nonatomic, retain) NSString * countryLocale;
@property (nonatomic, retain) NSString * countryCurrency;
@property (nonatomic, retain) NSString * countryLanguage;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSString * uniqueId;

@end
