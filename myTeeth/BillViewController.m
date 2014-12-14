//
//  BillViewController.m
//  myTeeth
//
//  Created by David Canty on 14/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "BillViewController.h"

@interface BillViewController ()


- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation BillViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Bar button actions
- (IBAction)cancelTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(billViewControllerDidCancel)]) {
        
        [self.delegate billViewControllerDidCancel];
    }
}

- (IBAction)doneTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(billViewControllerDidFinish)]) {
        
        [self.delegate billViewControllerDidFinish];
    }
}

@end