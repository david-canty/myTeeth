//
//  TeamMember+Utils.h
//  myTeeth
//
//  Created by David Canty on 10/07/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "TeamMember.h"

@interface TeamMember (Utils)

+ (NSUInteger)numberOfTeamMembers;
+ (TeamMember *)teamMemberWithUniqueId:(NSString *)uniqueId;

- (NSString *)fullNameWithTitle;

@end