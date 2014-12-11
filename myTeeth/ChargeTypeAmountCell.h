//
//  ChargeTypeAmountCell.h
//  myTeeth
//
//  Created by David Canty on 11/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChargeTypeAmountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountDetailLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

@end