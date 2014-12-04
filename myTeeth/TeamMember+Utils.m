//
//  TeamMember+Utils.m
//  myTeeth
//
//  Created by David Canty on 10/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "TeamMember+Utils.h"
#import "AppDelegate.h"

@implementation TeamMember (Utils)

+ (NSUInteger)numberOfTeamMembers {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TeamMember" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger numberOfTeamMembers = [moc countForFetchRequest:request error:&err];
    
    return numberOfTeamMembers;
}

+ (TeamMember *)teamMemberWithUniqueId:(NSString *)uniqueId {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamMember" inManagedObjectContext:moc];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array != nil) {
        
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if (count != 0) {
            
            TeamMember *teamMember = array[0];
            return teamMember;
            
        } else {
            
            NSLog(@"Error getting team member with unique id: %@, deleted?", uniqueId);
        }
        
    } else {
        
        NSLog(@"Error getting team member with unique id: %@", uniqueId);
    }
    
    return nil;
}

- (NSString *)fullNameWithTitle {
    if ([self.otherNames length] > 0) {
        return [NSString stringWithFormat:@"%@ %@ %@ %@", self.teamMemberTitle,self.firstName,self.otherNames,self.lastName];
    } else {
        return [NSString stringWithFormat:@"%@ %@ %@", self.teamMemberTitle,self.firstName,self.lastName];
    }
}

@end