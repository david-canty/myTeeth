//
//  DateOfBirthViewController.m
//  myTeeth
//
//  Created by David Canty on 25/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "DateOfBirthViewController.h"

@interface DateOfBirthViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)done:(id)sender;

@end

@implementation DateOfBirthViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!self.datePickerDate) {

        self.datePickerDate = [[NSDate alloc] init];
    }
    
    [self.datePicker setDate:self.datePickerDate animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (IBAction)done:(id)sender {
    
    [self.delegate dateOfBirthViewControllerDidFinish:self WithDate:[self.datePicker date]];
}

@end