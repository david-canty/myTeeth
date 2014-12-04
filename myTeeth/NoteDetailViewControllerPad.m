//
//  NoteDetailViewControllerPad.m
//  myTeeth
//
//  Created by David Canty on 06/04/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "NoteDetailViewControllerPad.h"

@interface NoteDetailViewControllerPad ()

- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation NoteDetailViewControllerPad

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

- (IBAction)cancelTapped:(id)sender {
    
    [self.delegate noteDetailViewControllerDelegateShouldCancel];
}

- (IBAction)doneTapped:(id)sender {
    
    [self.delegate noteDetailViewControllerDelegateShoudAddNote:self];
}

@end