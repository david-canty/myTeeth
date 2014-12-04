//
//  ToothReferenceViewController.m
//  myTeeth
//
//  Created by David Canty on 02/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ToothReferenceViewController.h"

@interface ToothReferenceViewController ()

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation ToothReferenceViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

- (IBAction)doneButtonTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end