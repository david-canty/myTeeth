//
//  Patient+Utils.m
//  myTeeth
//
//  Created by David Canty on 10/05/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Patient+Utils.h"
#import "AppDelegate.h"

@implementation Patient (Utils)

+ (NSUInteger)numberOfPatients {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfPatients = [moc countForFetchRequest:request error:&err];
    
    return numberOfPatients;
}

+ (BOOL)patientExistsWithObjectId:(NSManagedObjectID *)objId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"objectID == %@", objId];
    request.predicate = predicate;
    NSError *err;
    NSUInteger numberOfPatients = [moc countForFetchRequest:request error:&err];
    if (numberOfPatients == 0) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)patientExistsWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Patient" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    request.predicate = predicate;
    NSError *err;
    NSUInteger numberOfPatients = [moc countForFetchRequest:request error:&err];
    if (numberOfPatients == 0) {
        return NO;
    }
    
    return YES;
}

+ (Patient *)patientWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            Patient *patient = array[0];
            return patient;
            
        } else {
            
            NSLog(@"Error getting patient with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting patient with unique id: %@", uniqueId);
    }
    
    return nil;
}

+ (NSArray *)allPatients {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        return array;
        
    } else {
        
        NSLog(@"Error getting all patients");
    }
    
    return nil;
}

- (NSString *)fullNameWithTitle {
    if ([self.otherNames length] > 0) {
        return [NSString stringWithFormat:@"%@ %@ %@ %@", self.patientTitle,self.firstName,self.otherNames,self.lastName];
    } else {
        return [NSString stringWithFormat:@"%@ %@ %@", self.patientTitle,self.firstName,self.lastName];
    }
}

@end
