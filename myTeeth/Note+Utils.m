//
//  Note+Utils.m
//  myTeeth
//
//  Created by David Canty on 26/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Note+Utils.h"
#import "AppDelegate.h"

@implementation Note (Utils)

+ (instancetype)noteWithString:(NSString *)noteString {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    // Created & Modified
    NSDate *createdDate = [NSDate date];
    [note setCreated:createdDate];
    [note setModified:createdDate];
    
    // Title & Note
    [note setTitle:[NSString stringWithFormat:@"Appointment (%@)", createdDate]];
    [note setNote:noteString];
    
    // Unique id
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [note setUniqueId:uuid];
    
    // Save the context.
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return note;
}

@end