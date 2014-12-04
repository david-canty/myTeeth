//
//  DentalPractice+Utils.m
//  myTeeth
//
//  Created by David Canty on 20/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "DentalPractice+Utils.h"
#import "AppDelegate.h"

@implementation DentalPractice (Utils)

+ (NSString *)dentalPracticeContactId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DentalPractice" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
            
        DentalPractice *dentalPractice = array[0];
        return dentalPractice.contactId;
        
    } else {
        
        NSLog(@"Error getting dental practice");
    }
    
    return nil;
}

+ (NSString *)dentalPracticeName {
    
    NSString *practiceName = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DentalPractice" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        DentalPractice *dentalPractice = array[0];
        practiceName = dentalPractice.name;
        
    } else {
        
        NSLog(@"Error getting dental practice name");
    }
    
    return practiceName;
}

+ (void)setDentalPracticeContactId:(NSString *)contactId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DentalPractice" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
            
        DentalPractice *dentalPractice = array[0];
        dentalPractice.contactId = contactId;
        
        // Save the context.
        NSError *mocError = nil;
        if (![moc save:&mocError]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    } else {
        
        NSLog(@"Error setting dental practice contacts id");
    }
}

+ (void)setDentalPracticeName:(NSString *)practiceName {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DentalPractice" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        DentalPractice *dentalPractice = array[0];
        dentalPractice.name = practiceName;
        
        // Save the context.
        NSError *mocError = nil;
        if (![moc save:&mocError]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    } else {
        
        NSLog(@"Error setting dental practice name");
    }
}

@end