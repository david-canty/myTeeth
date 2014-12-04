//
//  Appointment+Utils.m
//  myTeeth
//
//  Created by David Canty on 23/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "Appointment+Utils.h"
#import "AppDelegate.h"

@implementation Appointment (Utils)

+ (NSUInteger)numberOfAppointments {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfAppointments = [moc countForFetchRequest:request error:&err];
    
    return numberOfAppointments;
}

+ (NSDate *)dateOfLastAppointment {
    
    NSDate *lastAppointmentDate = [NSDate date];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setFetchLimit:20];

    NSError *err;
    NSArray *appointments = [moc executeFetchRequest:request error:&err];
    
    if ([appointments count] > 0) {
        
        Appointment *lastAppointment = appointments[0];
        lastAppointmentDate = lastAppointment.dateTime;
    }

    return lastAppointmentDate;
}

@end