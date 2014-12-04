//
//  ChargeType+Utils.m
//  myTeeth
//
//  Created by David Canty on 27/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeType+Utils.h"
#import "AppDelegate.h"

@implementation ChargeType (Utils)

+ (NSUInteger)numberOfChargeTypes {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ChargeType" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfChargeTypes = 0;
    numberOfChargeTypes = [moc countForFetchRequest:request error:&err];
    
    return numberOfChargeTypes;
}

+ (void)loadChargeTypes {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Charge Types" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *chargeTypes = dict[@"ChargeTypes"];
    
    for (NSDictionary *chargeTypeDetails in chargeTypes) {
        
        ChargeType *chargeType  = (ChargeType *)[NSEntityDescription insertNewObjectForEntityForName:@"ChargeType" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [chargeType setUniqueId:uuid];
        
        // Charge type name
        [chargeType setChargeType:chargeTypeDetails[@"Charge Type"]];
        
        // Charge type description
        [chargeType setChargeTypeDescription:chargeTypeDetails[@"Description"]];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading charge types. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (ChargeType *)chargeTypeWithName:(NSString *)name {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChargeType" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chargeType == %@", name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            ChargeType *chargeType = array[0];
            return chargeType;
            
        } else {
            
            NSLog(@"Error getting charge type with name: %@, deleted?", name);
        }
        
    } else {
        
        NSLog(@"Error getting charge type with name: %@", name);
    }
    
    return nil;
}

@end