//
//  DurationViewController.h
//  myTeeth-iPad
//
//  Created by David Canty on 20/05/2012.
//  Copyright (c) 2012 ddijitall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DurationViewControllerDelegate;

@interface DurationViewController : UIViewController

@property (weak, nonatomic) id <DurationViewControllerDelegate> delegate;
@property (assign, nonatomic) NSTimeInterval pickerDuration;

@end

@protocol DurationViewControllerDelegate

- (void)DurationViewControllerDidFinish:(DurationViewController *)controller WithDuration:(NSTimeInterval)duration;

@end