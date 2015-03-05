//
//  TraitOverrideViewController.m
//  myTeeth
//
//  Created by David Canty on 05/03/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "TraitOverrideViewController.h"

@interface TraitOverrideViewController ()

@property (copy, nonatomic) UITraitCollection *forcedTraitCollection;

@end

@implementation TraitOverrideViewController

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    if (size.width > 320.0) {
        
        // If we are large enough, force a regular size class
        self.forcedTraitCollection = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
        
    } else {
        
        // Otherwise, don't override any traits
        self.forcedTraitCollection = nil;
    }
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)updateForcedTraitCollection {
    
    // Use our forcedTraitCollection to override our child's traits
    [self setOverrideTraitCollection:self.forcedTraitCollection forChildViewController:self.viewController];
}

- (void)setViewController:(UIViewController *)viewController {
    
    if (_viewController != viewController) {
        
        if (_viewController) {
            
            [_viewController willMoveToParentViewController:nil];
            [self setOverrideTraitCollection:nil forChildViewController:_viewController];
            [_viewController.view removeFromSuperview];
            [_viewController removeFromParentViewController];
        }
        
        if (viewController) {
            
            [self addChildViewController:viewController];
        }
        _viewController = viewController;
        
        if (_viewController) {
            
            UIView *view = _viewController.view;
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:view];
            NSDictionary *views = NSDictionaryOfVariableBindings(view);
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
            [_viewController didMoveToParentViewController:self];
            
            [self updateForcedTraitCollection];
        }
    }
}

- (void)setForcedTraitCollection:(UITraitCollection *)forcedTraitCollection {
    
    if (_forcedTraitCollection != forcedTraitCollection) {
        
        _forcedTraitCollection = [forcedTraitCollection copy];
        [self updateForcedTraitCollection];
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    
    return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    
    return YES;
}

@end