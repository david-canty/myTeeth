//
//  AddTeamMemberViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 21/04/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamMember;

@protocol AddTeamMemberViewControllerDelegate;

@interface AddTeamMemberViewController : UITableViewController {
    
}

@property (weak, nonatomic) id <AddTeamMemberViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) TeamMember *editingTeamMember;

@end

@protocol AddTeamMemberViewControllerDelegate <NSObject>

- (void)addTeamMemberViewControllerDidFinishWithTeamMember:(TeamMember *)teamMember;

@end