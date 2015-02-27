//
//  AppointmentHistoryCell.h
//  myTeeth
//
//  Created by David Canty on 26/02/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDateTimeLabel;

@end