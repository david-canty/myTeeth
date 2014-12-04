//
//  JobTitle+Utils.m
//  myTeeth
//
//  Created by David Canty on 09/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "JobTitle+Utils.h"
#import "AppDelegate.h"

@implementation JobTitle (Utils)

+ (NSUInteger)numberOfJobTitles {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"JobTitle" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfJobTitles = 0;
    numberOfJobTitles = [moc countForFetchRequest:request error:&err];
    
    return numberOfJobTitles;
}

+ (void)loadJobTitles {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Job Titles" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *jobTitles = dict[@"JobTitles"];
    
    for (NSString *jobTitle in jobTitles) {
        
        JobTitle *jobTitleObject = (JobTitle *)[NSEntityDescription insertNewObjectForEntityForName:@"JobTitle" inManagedObjectContext:moc];
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [jobTitleObject setUniqueId:uuid];
        
        // Job title
        [jobTitleObject setJobTitle:jobTitle];
        
        // Save the context
        NSError *error = nil;
        if (![moc save:&error]) {
            
            NSLog(@"Error loading job titles. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (JobTitle *)jobTitleWithName:(NSString *)name {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JobTitle" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobTitle == %@", name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            JobTitle *jobTitle = array[0];
            return jobTitle;
            
        } else {
            
            NSLog(@"Error getting job title with name: %@, deleted?", name);
        }
        
    } else {
        
        NSLog(@"Error getting job title with name: %@", name);
    }
    
    return nil;
}

@end