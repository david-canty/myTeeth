//
//  DateTimeViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 20/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateTimeViewControllerDelegate;

@interface DateTimeViewController : UIViewController

@property (weak, nonatomic) id <DateTimeViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDate *datePickerDate;

@end

@protocol DateTimeViewControllerDelegate

- (void)DateTimeViewControllerDidFinish:(DateTimeViewController *)controller WithDate:(NSDate *)date;

@end