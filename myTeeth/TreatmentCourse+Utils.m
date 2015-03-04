//
//  TreatmentCourse+Utils.m
//  myTeeth
//
//  Created by David Canty on 02/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "TreatmentCourse+Utils.h"
#import "AppDelegate.h"

@implementation TreatmentCourse (Utils)

+ (NSUInteger)numberOfTreatmentCourses {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TreatmentCourse" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfCourses = [moc countForFetchRequest:request error:&err];
    
    return numberOfCourses;
}

+ (TreatmentCourse *)treatmentCourseWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentCourse" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            TreatmentCourse *treatmentCourse = array[0];
            return treatmentCourse;
            
        } else {
            
            NSLog(@"Error getting treatment course with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting treatment course with unique id: %@", uniqueId);
    }
    
    return nil;
}

@end