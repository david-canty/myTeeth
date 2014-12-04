//
//  AppointmentViewController.h
//  myTeeth
//
//  Created by David Canty on 16/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end