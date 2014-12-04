//
//  ToothDetailViewController.m
//  myTeeth
//
//  Created by David Canty on 24/05/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ToothDetailViewController.h"

@interface ToothDetailViewController ()

- (IBAction)doneTapped:(id)sender;

@end

@implementation ToothDetailViewController

- (void)awakeFromNib {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = self.toothName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
