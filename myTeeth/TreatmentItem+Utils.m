//
//  TreatmentItem+Utils.m
//  myTeeth
//
//  Created by David Canty on 26/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "TreatmentItem+Utils.h"
#import "TreatmentCategory+Utils.h"
#import "AppDelegate.h"

@implementation TreatmentItem (Utils)

+ (void)loadDefaultTreatmentItems {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Categories must already exist
    if ([defaults stringForKey:@"xDefaultTreatmentCategoriesInitialized"] == nil) {
        [TreatmentCategory loadDefaultTreatmentCategories];
    }
    
    if ([defaults stringForKey:@"xDefaultTreatmentItemsInitialized"] == nil) {
        
        NSString *defaultTreatmentItemsPList = [[NSBundle mainBundle] pathForResource:@"DefaultTreatmentCategoriesAndItems" ofType:@"plist"];
        NSDictionary *defaultTreatmentItemsDict = [[NSDictionary alloc] initWithContentsOfFile:defaultTreatmentItemsPList];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        
        // Loop through all default categories and get all related treatment items
        NSArray *defaultTreatmentCategories = [defaultTreatmentItemsDict allKeys];
        for (NSString *defaultCategory in defaultTreatmentCategories) {
            
            NSArray *categoryItems = [defaultTreatmentItemsDict valueForKey:defaultCategory];
            
            for (NSString *defaultItem in categoryItems) {
                
                if ([defaultItem length] > 0) {
                    
                    // Create treatment item
                    TreatmentItem *treatmentItem = (TreatmentItem *)[NSEntityDescription insertNewObjectForEntityForName:@"TreatmentItem" inManagedObjectContext:managedObjectContext];
                    
                    [treatmentItem setItemName:defaultItem];
                    NSString *uuid = [[NSUUID UUID] UUIDString];
                    [treatmentItem setUniqueId:uuid];
                    
                    // Add relationship between treatment item and this treatment category
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    NSEntityDescription *category = [NSEntityDescription entityForName:@"TreatmentCategory" inManagedObjectContext:managedObjectContext];
                    [request setEntity:category];
                    
                    // Retrieve the objects with a given value for a certain property
                    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"categoryName == %@", defaultCategory];
                    [request setPredicate:predicate];
                    
                    // Edit the sort key as appropriate.
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
                    NSArray *sortDescriptors = @[sortDescriptor];
                    [request setSortDescriptors:sortDescriptors];
                    
                    NSError *error = nil;
                    NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
                    if ((result != nil) && ([result count]) && (error == nil)) {
                        TreatmentCategory *thisCategory = result[0];
                        [thisCategory addTreatmentItemsObject:treatmentItem];
                    }
                }
            }
        }
        
        // Save the context
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [defaults setObject:@"Default Treatment Items Initialized" forKey:@"xDefaultTreatmentItemsInitialized"];
        [defaults synchronize];
    }
}

+ (instancetype)treatmentItemWithUniqueID:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentItem" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            TreatmentItem *treatmentItem = array[0];
            return treatmentItem;
            
        } else {
            
            NSLog(@"Error getting treatment item with unique id: %@, (deleted?)", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting treatment item with unique id: %@", uniqueId);
    }
    
    return nil;
}

@end