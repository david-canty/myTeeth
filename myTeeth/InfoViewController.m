//
//  InfoViewController.m
//  myTeeth
//
//  Created by David Canty on 08/01/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "InfoViewController.h"
#import "Constants.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation InfoViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSString *infoString = NSLocalizedString(@"Thank you for downloading and using myTeeth.\n\nPlease get in touch if you would like to suggest a new feature or improvement to myTeeth, or if you have discovered a bug.\n\nAll feedback from your experience using the app is valuable, appreciated and will help with future versions of myTeeth.\n\nIf you like myTeeth, rate it on the App Store now!", @"Info text");
    
    self.infoTextView.text = infoString;
    
    self.versionLabel.text = kAppVersion;
}

@end