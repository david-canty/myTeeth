//
//  AddPatientViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 10/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Patient;

@protocol AddPatientViewControllerDelegate;

@interface AddPatientViewController : UITableViewController {
    
}

@property (weak, nonatomic) id <AddPatientViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Patient *editingPatient;

@end

@protocol AddPatientViewControllerDelegate <NSObject>

- (void)addPatientViewControllerDidFinishWithPatient:(Patient *)patient;

@end