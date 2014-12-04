//
//  NoteDetailViewController.m
//  myTeeth
//
//  Created by Dave on 13/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "Constants.h"

@interface NoteDetailViewController ()
@property CGFloat keyboardOffset;
@property BOOL keyboardIsShowing;
@property BOOL titleTextFieldIsActive;
@property BOOL noteTextViewIsActive;
@property BOOL backspacingFirstCharacter;
@property BOOL activeFieldHasValidCharacters;
@end

@implementation NoteDetailViewController

#define k_ViewOffsetForNoteTextViewInLandscape      60
#define k_NoteTextViewHeightInLandscape             145
#define k_NoteTextViewHeightInLandscapeIsAdding     180
#define k_NoteTextViewHeightInPortrait              370
#define k_NoteTextViewHeightInPortraitIsAdding      414
#define k_NoteTextViewHeightInLandscapeWithKeyboard 45
#define k_NoteTextViewHeightInPortraitWithKeyboard  155

- (void)awakeFromNib {
    _isAdding = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isAdding) {
        self.navigationItem.title = NSLocalizedString(@"Add Note", @"Add Note");
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                                         style:UIBarButtonItemStyleDone target:self action:@selector(cancelTapped)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped)];
        self.navigationItem.rightBarButtonItem = doneButton;
        _flagIndicator.hidden = YES;
    } else {
        self.navigationItem.title = NSLocalizedString(@"Note", @"Note");
        _noteTitleTextField.text = _noteTitleText;
        _noteTextView.text = _noteText;
        
        _flagBarButtonItem.title = (_isFlagged) ? (NSLocalizedString(@"Unflag", @"Unflag")) : (NSLocalizedString(@"Flag", @"Flag"));
        _flagIndicator.hidden = (_isFlagged) ? NO : YES;
    }
    
    // set note textview height depending on orientation and is adding
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscapeIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscape;
                }
            }
        }
    }
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
        [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortraitIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortrait;
                }
            }
        }
    }
    
    [[_noteTextView layer] setBorderColor:[[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [[_noteTextView layer] setBorderWidth:1];
    [[_noteTextView layer] setCornerRadius:5];
    [_noteTextView  setTextContainerInset:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuControllerWillHideMenu:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuControllerDidHideMenu:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
    
    _keyboardAccessoryView.layer.borderWidth = 1.0;
    _keyboardAccessoryView.layer.borderColor = [[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor];
    _keyboardAccessoryView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    
    _keyboardIsShowing = NO;
    _titleTextFieldIsActive = NO;
    _noteTextViewIsActive = NO;
    _backspacingFirstCharacter = NO;
    _activeFieldHasValidCharacters = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (_isAdding) {
        _noteTitleTextField.textColor = [UIColor lightGrayColor];
        _noteTitleTextField.text = kNoteTitlePlaceholder;
        _noteTextView.textColor = [UIColor lightGrayColor];
        _noteTextView.text = kNoteMessagePlaceholder;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillLayoutSubviews {

}

- (void)doneTapped {
    if ([_noteTitleTextField.text length] > 0 &&
        ![_noteTitleTextField.text isEqualToString:kNoteTitlePlaceholder] &&
        [_noteTextView.text length] > 0 &&
        ![_noteTextView.text isEqualToString:kNoteMessagePlaceholder]) {
        [self.delegate noteDetailViewControllerDelegateShoudAddNote:self];
    }
}

- (void)cancelTapped {
    
    [self.delegate noteDetailViewControllerDelegateShouldCancel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerDidHideMenuNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
            if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = k_NoteTextViewHeightInLandscapeWithKeyboard;
            }
        }
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
            if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = k_NoteTextViewHeightInPortraitWithKeyboard;
            }
        }
    }
    _keyboardIsShowing = YES;
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscapeIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscape;
                }
            }
        }
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortraitIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortrait;
                }
            }
        }
    }
    _keyboardIsShowing = NO;
}

- (void)menuControllerWillHideMenu:(NSNotification *)notification {
    if (_noteTitleTextField.text.length == 0 ||
        _noteTextView.text.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)menuControllerDidHideMenu:(NSNotification *)notification {
    if (_noteTitleTextField.text.length == 0 ||
        _noteTextView.text.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)validateForDoneButton {
    if ((_noteTitleTextField.text.length > 0 &&
        ![_noteTitleTextField.text isEqualToString:kNoteTitlePlaceholder] &&
         _noteTextViewIsActive &&
         ((_noteTextView.text.length > 0) || _activeFieldHasValidCharacters)) ||
        (_noteTextView.text.length > 0 &&
        ![_noteTextView.text isEqualToString:kNoteMessagePlaceholder] &&
         _titleTextFieldIsActive &&
         ((_noteTitleTextField.text.length > 0) || _activeFieldHasValidCharacters))) {
            if (_backspacingFirstCharacter == NO) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
            } else {
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    _backspacingFirstCharacter = NO;
    _activeFieldHasValidCharacters = NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscapeIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscape;
                }
            }
        }
    }
    if (toInterfaceOrientation == UIDeviceOrientationPortrait ||
        toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortraitIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInPortrait;
                }
            }
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        if (_keyboardIsShowing && !_titleTextFieldIsActive) {
            // scroll to accommodate keyboard in landscape
            [self scrollViewToAccommodateKeyboardShowInLandscape];
        }
    } else {
        if (_keyboardIsShowing) {
            // scroll view back from accommodating keyboard in landscape
            [self scrollViewToAccommodateKeyboardHideInLandscape];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteNote:(id)sender {
    UIActionSheet *deleteConfirmationActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:@"Delete Note" otherButtonTitles:nil, nil];
    [deleteConfirmationActionSheet showFromBarButtonItem:_deleteBarButtonItem animated:YES];
}

// action sheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.delegate noteDetailViewControllerDelegateShoudDeleteNote:self];
    }
}

// flag note
- (IBAction)flagNote:(id)sender {
    _isFlagged = !_isFlagged;
    _flagBarButtonItem.title = (_isFlagged) ? (NSLocalizedString(@"Unflag", @"Unflag")) : (NSLocalizedString(@"Flag", @"Flag"));
    _flagIndicator.hidden = (_isFlagged) ? NO : YES;
    [self.delegate updateNoteFlag:_isFlagged];
}

// textfield delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_noteTitleTextField.textColor == [UIColor lightGrayColor]) {
        _noteTitleTextField.text = @"";
        _noteTitleTextField.textColor = [UIColor blackColor];
    }
    if (_noteTitleTextField.inputAccessoryView == nil) {
        _noteTitleTextField.inputAccessoryView = _keyboardAccessoryView;
    }
    _titleTextFieldIsActive = YES;
    _noteTextViewIsActive = NO;
    [self validateForDoneButton];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    if (textField.text.length == 1 &&
        [string isEqualToString:@""]) {
        _backspacingFirstCharacter = YES;
    } else if (textField.text.length == 0 &&
               ![string isEqualToString:@""]) {
        _activeFieldHasValidCharacters = YES;
        _noteTitleTextField.textColor = [UIColor blackColor];
    }
    [self validateForDoneButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        _noteTitleTextField.textColor = [UIColor lightGrayColor];
        _noteTitleTextField.text = kNoteTitlePlaceholder;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _titleTextFieldIsActive = NO;
    if ([_noteTitleTextField.text length] == 0) {
        _noteTitleTextField.textColor = [UIColor lightGrayColor];
        _noteTitleTextField.text = kNoteTitlePlaceholder;
    }
    // save title immediately if not adding
    if (_noteTitleTextField.text.length > 0 &&
        ![_noteTitleTextField.text isEqualToString:kNoteTitlePlaceholder] &&
        !_isAdding) {
        [self.delegate updateNoteTitle:_noteTitleTextField.text];
    }
}

// textview delegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (_noteTextView.textColor == [UIColor lightGrayColor]) {
        _noteTextView.text = @"";
        _noteTextView.textColor = [UIColor blackColor];
    }
    if (_noteTextView.inputAccessoryView == nil) {
        _noteTextView.inputAccessoryView = _keyboardAccessoryView;
    }
    // scroll to accommodate keyboard in landscape
    [self scrollViewToAccommodateKeyboardShowInLandscape];
    _noteTextViewIsActive = YES;
    _titleTextFieldIsActive = NO;
    [self validateForDoneButton];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    // scroll view back from accommodating keyboard in landscape
    [self scrollViewToAccommodateKeyboardHideInLandscape];
    if ([_noteTextView.text length] == 0) {
        _noteTextView.textColor = [UIColor lightGrayColor];
        _noteTextView.text = kNoteMessagePlaceholder;
    }
    _noteTextViewIsActive = NO;
    
    // save note text immediately if not adding
    if (_noteTextView.text.length > 0 &&
        ![_noteTextView.text isEqualToString:kNoteMessagePlaceholder] &&
        !_isAdding) {
        [self.delegate updateNoteNote:_noteTextView.text];
    }

    return YES;
}

- (void)scrollViewToAccommodateKeyboardShowInLandscape {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33f];
        CGRect frame = self.view.frame;
        frame.origin.y = -k_ViewOffsetForNoteTextViewInLandscape;
        [self.view setFrame:frame];
        [UIView commitAnimations];
    }
}

- (void)scrollViewToAccommodateKeyboardHideInLandscape {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33f];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self.view setFrame:frame];
        [UIView commitAnimations];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ( _noteTextView.text.length == 0) {
        _noteTextView.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
    if (textView.text.length == 1 &&
        [text isEqualToString:@""]) {
        _backspacingFirstCharacter = YES;
    } else if (textView.text.length == 0 &&
              ![text isEqualToString:@""]) {
        _activeFieldHasValidCharacters = YES;
        _noteTextView.textColor = [UIColor blackColor];
    }

    [self validateForDoneButton];
    return YES;
}

// keyboard accessory view buttons
- (IBAction)keyboardTitleButtonTapped:(id)sender {
    _titleTextFieldIsActive = YES;
    _noteTextViewIsActive = NO;
    
    // save note text immediately if not adding
    if (_noteTextView.text.length > 0 &&
        ![_noteTextView.text isEqualToString:kNoteMessagePlaceholder] &&
        !_isAdding) {
        [self.delegate updateNoteNote:_noteTextView.text];
    }
    
    [_noteTitleTextField becomeFirstResponder];
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33f];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self.view setFrame:frame];
        [UIView commitAnimations];
    }
}

- (IBAction)keyboardNoteButtonTapped:(id)sender {
    _noteTextViewIsActive = YES;
    _titleTextFieldIsActive = NO;
    
    // save title immediately if not adding
    if (_noteTitleTextField.text.length > 0 &&
        ![_noteTitleTextField.text isEqualToString:kNoteTitlePlaceholder] &&
        !_isAdding) {
        [self.delegate updateNoteTitle:_noteTitleTextField.text];
    }
    
    [_noteTextView becomeFirstResponder];
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33f];
        CGRect frame = self.view.frame;
        frame.origin.y = -k_ViewOffsetForNoteTextViewInLandscape;
        [self.view setFrame:frame];
        [UIView commitAnimations];
    }
}

- (IBAction)keyboardDoneButtonTapped:(id)sender {
    _noteTextViewIsActive = NO;
    _titleTextFieldIsActive = NO;
    if (_noteTitleTextField.text.length == 0) {
        _noteTitleTextField.textColor = [UIColor lightGrayColor];
        _noteTitleTextField.text = kNoteTitlePlaceholder;
    } else {
        // save edited and validated field
        if (!_isAdding) {
            [self.delegate updateNoteTitle:_noteTitleTextField.text];
        }
    }
    [_noteTitleTextField resignFirstResponder];
    if (_noteTextView.text.length == 0) {
        _noteTextView.textColor = [UIColor lightGrayColor];
        _noteTextView.text = kNoteMessagePlaceholder;
    } else {
        // save edited and validated field
        if (!_isAdding) {
            [self.delegate updateNoteNote:_noteTextView.text];
        }
    }
    [_noteTextView resignFirstResponder];
    
    // correct view frame and textview constraints if in UIDeviceOrientationPortraitUpsideDown
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        // view
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.33f];
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self.view setFrame:frame];
        [UIView commitAnimations];
        
        // textview constraints
        if (_isAdding) {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscapeIsAdding;
                }
            }
        } else {
            for(NSLayoutConstraint *constraint in _noteTextView.constraints) {
                if(constraint.firstAttribute == NSLayoutAttributeHeight) {
                    constraint.constant = k_NoteTextViewHeightInLandscape;
                }
            }
        }
    }
}

@end
