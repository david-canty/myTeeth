//
//  AppointmentCell.m
//  myTeeth
//
//  Created by David Canty on 17/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "AppointmentCell.h"

@implementation AppointmentCell

- (IBAction)cellTickButtonTapped:(id)sender {
    
    BOOL cellSelectedState = !self.cellTickButton.selected;
    [self setCellTickButtonSelectedState:cellSelectedState];
}

- (void)setCellTickButtonSelectedState:(BOOL)selectedState {
    
    self.cellTickButton.selected = selectedState;
}

@end