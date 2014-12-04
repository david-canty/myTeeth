//
//  NoteViewController_iPad.h
//  myTeeth
//
//  Created by David Canty on 24/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NoteViewControllerDelegate;

@interface NoteViewController_iPad : UIViewController

@property (weak, nonatomic) id <NoteViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *noteString;

@end

@protocol NoteViewControllerDelegate

- (void)noteViewControllerDelegateDidFinish:(NoteViewController_iPad *)controller withNote:(NSString *)note;

@end