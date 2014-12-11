//
//  ServiceProvider+Utils.m
//  myTeeth
//
//  Created by David Canty on 27/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ServiceProvider+Utils.h"
#import "AppDelegate.h"

@implementation ServiceProvider (Utils)

+ (NSUInteger)numberOfServiceProviders {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ServiceProvider" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfServiceProviders = 0;
    numberOfServiceProviders = [moc countForFetchRequest:request error:&err];
    
    return numberOfServiceProviders;
}

+ (void)loadServiceProviders {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Service Providers" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *serviceProviders = dict[@"ServiceProviders"];
    
    for (NSDictionary *serviceProviderDetails in serviceProviders) {
        
        ServiceProvider *serviceProvider  = (ServiceProvider *)[NSEntityDescription insertNewObjectForEntityForName:@"ServiceProvider" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [serviceProvider setUniqueId:uuid];
        
        // Service provider name
        [serviceProvider setProviderName:serviceProviderDetails[@"Service Provider"]];
        
        // Service provider description
        [serviceProvider setProviderDescription:serviceProviderDetails[@"Description"]];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading service providers. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (ServiceProvider *)serviceProviderWithName:(NSString *)name {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ServiceProvider" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"providerName == %@", name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            ServiceProvider *serviceProvider = array[0];
            return serviceProvider;
            
        } else {
            
            NSLog(@"Error getting service provider with name: %@, deleted?", name);
        }
        
    } else {
        
        NSLog(@"Error getting service provider with name: %@", name);
    }
    
    return nil;
}

+ (ServiceProvider *)serviceProviderWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ServiceProvider" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            ServiceProvider *serviceProvider = array[0];
            return serviceProvider;
            
        } else {
            
            NSLog(@"Error getting service provider with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting service provider with unique id: %@", uniqueId);
    }
    
    return nil;
}

@end