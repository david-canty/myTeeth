//
//  PaymentMethod+Utils.m
//  myTeeth
//
//  Created by David Canty on 31/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "PaymentMethod+Utils.h"
#import "AppDelegate.h"

@implementation PaymentMethod (Utils)

+ (NSUInteger)numberOfPaymentMethods {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PaymentMethod" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfPaymentMethods = 0;
    numberOfPaymentMethods = [moc countForFetchRequest:request error:&err];
    
    return numberOfPaymentMethods;
}

+ (void)loadPaymentMethods {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Payment Methods" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *paymentMethods = dict[@"PaymentMethods"];
    
    for (NSDictionary *paymentMethodDetails in paymentMethods) {
        
        PaymentMethod *paymentMethod = (PaymentMethod *)[NSEntityDescription insertNewObjectForEntityForName:@"PaymentMethod" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [paymentMethod setUniqueId:uuid];
        
        // Payment method name
        [paymentMethod setPaymentMethod:paymentMethodDetails[@"Payment Method"]];
        
        // Payment method description
        [paymentMethod setPaymentMethodDescription:paymentMethodDetails[@"Description"]];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading payment methods. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (PaymentMethod *)paymentMethodWithName:(NSString *)name {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaymentMethod" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"paymentMethod == %@", name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            PaymentMethod *paymentMethod = array[0];
            return paymentMethod;
            
        } else {
            
            NSLog(@"Error getting payment method with name: %@, deleted?", name);
        }
        
    } else {
        
        NSLog(@"Error getting payment method with name: %@", name);
    }
    
    return nil;
}

@end