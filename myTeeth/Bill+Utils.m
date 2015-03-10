//
//  Bill+Utils.m
//  myTeeth
//
//  Created by David Canty on 10/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "Bill+Utils.h"
#import "AppDelegate.h"

@implementation Bill (Utils)

+ (NSUInteger)numberOfBills {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Bill" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfBills = 0;
    numberOfBills = [moc countForFetchRequest:request error:&err];
    
    return numberOfBills;
}

@end