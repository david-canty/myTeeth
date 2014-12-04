//
//  NoteViewController_iPad.m
//  myTeeth
//
//  Created by David Canty on 24/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "NoteViewController_iPad.h"

#define k_NoteTextViewHeightInPortrait              536
#define k_NoteTextViewHeightInPortraitWithKeyboard  467
#define k_NoteTextViewHeightInLandscape             536
#define k_NoteTextViewHeightInLandscapeWithKeyboard 314

@interface NoteViewController_iPad () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation NoteViewController_iPad

#pragma mark - View lifecycle
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.noteString = @"";
}

- (void)viewDidLoad{
    
    [super viewDidLoad];

    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Display note
    self.noteTextView.text = self.noteString;
    
    // Adjust note textview height depending on device orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {

        for (NSLayoutConstraint *constraint in self.noteTextView.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                
                constraint.constant = k_NoteTextViewHeightInLandscapeWithKeyboard;
            }
        }
    }
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {

        for (NSLayoutConstraint *constraint in self.noteTextView.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                
                constraint.constant = k_NoteTextViewHeightInPortraitWithKeyboard;
            }
        }
    }
    
    // Set textview border
    [[_noteTextView layer] setBorderColor:[[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [[_noteTextView layer] setBorderWidth:1];
    [[_noteTextView layer] setCornerRadius:5];
    [_noteTextView  setTextContainerInset:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Show keyboard
    [self.noteTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // De-Register keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard delegate
- (void)keyboardWillShow:(NSNotification *)notification {
    
    // Adjust textview for landscape with keyboard
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        
        for (NSLayoutConstraint *constraint in self.noteTextView.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                
                constraint.constant = k_NoteTextViewHeightInLandscapeWithKeyboard;
            }
        }
    }
    
    // Adjust textview for portrait with keyboard
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        
        for (NSLayoutConstraint *constraint in _noteTextView.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                
                constraint.constant = k_NoteTextViewHeightInPortraitWithKeyboard;
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Adjust textview for landscape without keyboard
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {

            for (NSLayoutConstraint *constraint in self.noteTextView.constraints) {
                
                if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                    
                    constraint.constant = k_NoteTextViewHeightInLandscape;
                }
            }
    }
    
    // Adjust textview for portrait without keyboard
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {

        for (NSLayoutConstraint *constraint in self.noteTextView.constraints) {
            
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                
                constraint.constant = k_NoteTextViewHeightInPortrait;
            }
        }
    }
}

#pragma mark - Button actions
- (IBAction)doneButtonTapped:(id)sender {
    
    [self.delegate noteViewControllerDelegateDidFinish:self withNote:self.noteTextView.text];
}

@end