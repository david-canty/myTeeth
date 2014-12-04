//
//  ToothCell.h
//  myTeeth-iPad
//
//  Created by Dave on 15/09/2013.
//  Copyright (c) 2013 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToothCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *toothBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *toothNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *toothReferenceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *toothImage;

@end