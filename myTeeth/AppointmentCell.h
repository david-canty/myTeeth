//
//  AppointmentCell.h
//  myTeeth
//
//  Created by David Canty on 17/10/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *cellTickButton;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDateTimeLabel;

- (IBAction)cellTickButtonTapped:(id)sender;
- (void)setCellTickButtonSelectedState:(BOOL)selectedState;

@end