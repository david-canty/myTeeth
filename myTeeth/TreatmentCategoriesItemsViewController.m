//
//  TreatmentCategoriesItemsViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 10/06/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "TreatmentCategoriesItemsViewController.h"
#import "TreatmentCategoriesViewController.h"
#import "TreatmentItemsViewController.h"

@interface TreatmentCategoriesItemsViewController ()

@end

@implementation TreatmentCategoriesItemsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowTreatmentCategoriesView"]) {
        TreatmentCategoriesViewController *controller = (TreatmentCategoriesViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowTreatmentItemsView"]) {
        TreatmentItemsViewController *controller = (TreatmentItemsViewController *)[segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
    }
}

@end