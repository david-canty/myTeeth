//
//  TreatmentCategory+Utils.m
//  myTeeth
//
//  Created by David Canty on 26/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "TreatmentCategory+Utils.h"
#import "AppDelegate.h"

@implementation TreatmentCategory (Utils)

+ (void)loadDefaultTreatmentCategories {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"xDefaultTreatmentCategoriesInitialized"] == nil) {
        
        NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
        NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
        NSArray *defaultTreatmentItemsDictKeys = [defaultTreatmentItemsDict allKeys];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        
        for (NSString *defaultCategory in defaultTreatmentItemsDictKeys) {
            
            TreatmentCategory *treatmentCategory = (TreatmentCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"TreatmentCategory" inManagedObjectContext:managedObjectContext];
            
            [treatmentCategory setCategoryName:defaultCategory];
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [treatmentCategory setUniqueId:uuid];
        }
        
        // Save the context
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [defaults setObject:@"Default Treatment Categories Initialized" forKey:@"xDefaultTreatmentCategoriesInitialized"];
        [defaults synchronize];
    }
}

@end