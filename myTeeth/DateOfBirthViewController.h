//
//  DateOfBirthViewController.h
//  myTeeth
//
//  Created by David Canty on 25/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateOfBirthViewControllerDelegate;

@interface DateOfBirthViewController : UIViewController

@property (weak, nonatomic) id <DateOfBirthViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDate *datePickerDate;

@end

@protocol DateOfBirthViewControllerDelegate

- (void)dateOfBirthViewControllerDidFinish:(DateOfBirthViewController *)controller WithDate:(NSDate *)date;

@end