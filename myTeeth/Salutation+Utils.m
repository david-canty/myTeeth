//
//  Salutation+Utils.m
//  myTeeth
//
//  Created by David Canty on 09/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Salutation+Utils.h"
#import "AppDelegate.h"

@implementation Salutation (Utils)

+ (NSUInteger)numberOfSalutations {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Salutation" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfSalutations = 0;
    numberOfSalutations = [moc countForFetchRequest:request error:&err];
    
    return numberOfSalutations;
}

+ (void)loadSalutations {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Salutations" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *salutations = dict[@"Salutations"];
    
    for (NSString *salutation in salutations) {
        
        Salutation *salutationObject = (Salutation *)[NSEntityDescription insertNewObjectForEntityForName:@"Salutation" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [salutationObject setUniqueId:uuid];
        
        // Salutation
        [salutationObject setSalutation:salutation];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading salutations. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (Salutation *)salutationWithName:(NSString *)name {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Salutation" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"salutation == %@", name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            Salutation *salutation = array[0];
            return salutation;
            
        } else {
            
            NSLog(@"Error getting salutation with name: %@, deleted?", name);
        }
        
    } else {
        
        NSLog(@"Error getting salutation with name: %@", name);
    }
    
    return nil;
}

@end