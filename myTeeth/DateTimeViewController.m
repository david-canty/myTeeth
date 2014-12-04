//
//  DateTimeViewController.m
//  myTeeth-iPad
//
//  Created by David Canty on 20/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import "DateTimeViewController.h"

@interface DateTimeViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)done:(id)sender;

@end

@implementation DateTimeViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.datePickerDate = [[NSDate alloc] init];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.datePicker setDate:self.datePickerDate animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return YES;
}

- (IBAction)done:(id)sender {
    [self.delegate DateTimeViewControllerDidFinish:self WithDate:[self.datePicker date]];
}

@end