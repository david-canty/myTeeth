//
//  ChargeType+Utils.m
//  myTeeth
//
//  Created by David Canty on 09/12/2014.
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

+ (ChargeType *)chargeTypeWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChargeType" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            ChargeType *chargeType = array[0];
            return chargeType;
            
        } else {
            
            NSLog(@"Error getting charge type with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting charge type with unique id: %@", uniqueId);
    }
    
    return nil;
}

@end