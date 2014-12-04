//
//  ChargeTypeDetailViewController_iPad.m
//  myTeeth
//
//  Created by David Canty on 28/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeTypeDetailViewController_iPad.h"

@interface ChargeTypeDetailViewController_iPad ()

- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation ChargeTypeDetailViewController_iPad

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navigationItem.title = self.navigationItemTitleString;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneTapped:(id)sender {
    
    [self.delegate chargeTypeDetailViewControllerDidFinish:self];
}

@end