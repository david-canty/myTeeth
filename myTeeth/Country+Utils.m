//
//  Country+Utils.m
//  myTeeth
//
//  Created by David Canty on 20/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Country+Utils.h"
#import "AppDelegate.h"

@implementation Country (Utils)

+ (NSUInteger)numberOfCountries {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Country" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfCountries = [moc countForFetchRequest:request error:&err];
    
    return numberOfCountries;
}

+ (Country *)countryWithLocale:(NSString *)countryLocale {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryLocale == %@", countryLocale];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            Country *country = array[0];
            return country;
            
        } else {
            
            NSLog(@"Error getting country with locale: %@, deleted?", countryLocale);
        }
        
    } else {
        
        NSLog(@"Error getting country with locale: %@", countryLocale);
    }
    
    return nil;
}

@end