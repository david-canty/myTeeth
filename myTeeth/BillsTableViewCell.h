//
//  BillsTableViewCell.h
//  myTeeth
//
//  Created by David Canty on 10/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentLabel;

@end