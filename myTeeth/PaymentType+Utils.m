//
//  PaymentType+Utils.m
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "PaymentType+Utils.h"
#import "ServiceProvider+Utils.h"
#import "PaymentMethod+Utils.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation PaymentType (Utils)

+ (NSUInteger)numberOfPaymentTypes {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PaymentType" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfPaymentTypes = 0;
    numberOfPaymentTypes = [moc countForFetchRequest:request error:&err];
    
    return numberOfPaymentTypes;
}

+ (void)loadPaymentTypes {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Payment Types" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *paymentTypes = dict[@"PaymentTypes"];
    
    for (NSDictionary *paymentTypeDetails in paymentTypes) {
        
        PaymentType *paymentType = (PaymentType *)[NSEntityDescription insertNewObjectForEntityForName:@"PaymentType" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [paymentType setUniqueId:uuid];
        
        // Payment type name
        [paymentType setTypeName:paymentTypeDetails[@"Payment Type"]];
        
        // Payment type description
        [paymentType setTypeDescription:paymentTypeDetails[@"Description"]];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading payment types. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (PaymentType *)paymentTypeWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaymentType" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            PaymentType *paymentType = array[0];
            return paymentType;
            
        } else {
            
            NSLog(@"Error getting payment type with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting payment type with unique id: %@", uniqueId);
    }
    
    return nil;
}

@end