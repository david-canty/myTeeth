//
//  DurationViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 20/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "DurationViewController.h"

@interface DurationViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)done:(id)sender;

@end

@implementation DurationViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (self.pickerDuration > 0) {
        [self.datePicker setCountDownDuration:self.pickerDuration];
    } else {
        [self.datePicker setCountDownDuration:600]; // default to 10 minutes
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (IBAction)done:(id)sender {
    
    [self.delegate DurationViewControllerDidFinish:self WithDuration:[self.datePicker countDownDuration]];
}

@end