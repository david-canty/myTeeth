//
//  AddAppointmentViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 13/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Appointment;

@protocol AddAppointmentViewControllerDelegate;

@interface AddAppointmentViewController : UITableViewController  {
    
}

@property (weak, nonatomic) id <AddAppointmentViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Appointment *appointment;
@property (assign, nonatomic) BOOL viewingAppointment;

@end

@protocol AddAppointmentViewControllerDelegate <NSObject>
- (void)addAppointmentViewControllerDidCancel:(AddAppointmentViewController *)controller;
- (void)addAppointmentViewControllerDidFinish:(AddAppointmentViewController *)controller;
@end