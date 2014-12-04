//
//  PaymentType+Utils.m
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "PaymentType+Utils.h"
#import "ChargeType+Utils.h"
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
        [paymentType setPaymentType:paymentTypeDetails[@"Payment Type"]];
        
        // Payment type description
        [paymentType setPaymentTypeDescription:paymentTypeDetails[@"Description"]];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading payment types. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end