//
//  NoteDetailViewController.h
//  myTeeth
//
//  Created by Dave on 13/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteDetailViewControllerDelegate;

@interface NoteDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) id <NoteDetailViewControllerDelegate> delegate;

@property BOOL isAdding;
@property (strong, nonatomic) NSString *noteTitleText;
@property (strong, nonatomic) NSString *noteText;

@property (weak, nonatomic) IBOutlet UITextField *noteTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

@property (strong, nonatomic) IBOutlet UIView *keyboardAccessoryView;
- (IBAction)keyboardTitleButtonTapped:(id)sender;
- (IBAction)keyboardNoteButtonTapped:(id)sender;
- (IBAction)keyboardDoneButtonTapped:(id)sender;

- (IBAction)deleteNote:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;

@property BOOL isFlagged;
- (IBAction)flagNote:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flagBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *flagIndicator;

@end

@protocol NoteDetailViewControllerDelegate <NSObject>

- (void)noteDetailViewControllerDelegateShoudDeleteNote:(NoteDetailViewController *)controller;
- (void)noteDetailViewControllerDelegateShoudAddNote:(NoteDetailViewController *)controller;
- (void)noteDetailViewControllerDelegateShouldCancel;
- (void)updateNoteTitle:(NSString *)noteTitle;
- (void)updateNoteNote:(NSString *)noteNote;
- (void)updateNoteFlag:(BOOL)isFlagged;

@end
