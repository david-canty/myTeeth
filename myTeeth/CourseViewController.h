//
//  CourseViewController.h
//  myTeeth
//
//  Created by David Canty on 28/02/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TreatmentCourse;

@protocol CourseViewControllerDelegate;

@interface CourseViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <CourseViewControllerDelegate> delegate;
@property (strong, nonatomic) TreatmentCourse *selectedCourse;

@end

@protocol CourseViewControllerDelegate <NSObject>
- (void)courseViewControllerDidFinishWithCourse:(TreatmentCourse *)course;
@end