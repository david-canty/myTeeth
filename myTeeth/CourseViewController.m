//
//  CourseViewController.m
//  myTeeth
//
//  Created by David Canty on 28/02/2015.
//  Copyright (c) 2015 David Canty. All rights reserved.
//

#import "CourseViewController.h"
#import "TreatmentCourse+Utils.h"

static NSString *kCourseCellIdentifier = @"CourseCellIdentifier";

@interface CourseViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedCourseIndexPath;

@property (weak, nonatomic) IBOutlet UITextField *courseNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;

- (IBAction)addCourseTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation CourseViewController

- (void)awakeFromNib {
    
    [super awakeFromNib];

    self.selectedCourseIndexPath = nil;
    self.selectedCourse = nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Check selected course row
    if (self.selectedCourse != nil) {
        
        self.selectedCourseIndexPath = [self.fetchedResultsController indexPathForObject:self.selectedCourse];
    }
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Prevent space at beginning
    if (range.location == 0 && [string isEqualToString:@" "]) {
        
        return NO;
    }
    
    // Enable backspace
    if (range.length > 0 && [string length] == 0) {
        
        return YES;
    }
    
    // Allowed characters
    NSString *validCharacters = [NSString stringWithFormat:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -"];
    NSCharacterSet *invalidCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:validCharacters] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        TreatmentCourse *treatmentCourse = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        if (treatmentCourse.appointments.count > 0) {
            
            UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Delete Course"
                                                                                 message:@"\nDeleting this course will not delete any of its associated appointments but will leave them not assigned to a course.\n\nAre you sure you wish to delete this treatment course?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
                                                                 
                                                                 [self.managedObjectContext deleteObject:treatmentCourse];
                                                                 
                                                                 NSError *error = nil;
                                                                 if (![self.managedObjectContext save:&error]) {
                                                                     
                                                                     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                                     abort();
                                                                 }
                                                             }];
            [deleteAlert addAction:okAction];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [deleteAlert addAction:cancelAction];
            
            [self presentViewController:deleteAlert animated:YES completion:nil];
            
        } else {
            
            [self.managedObjectContext deleteObject:treatmentCourse];
            
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourseCellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger newRow = [indexPath indexAtPosition:1];
    NSInteger oldRow = [self.selectedCourseIndexPath indexAtPosition:1];
    
    if (newRow != oldRow || self.selectedCourseIndexPath == nil) {
        
        // Set selected course
        TreatmentCourse *treatmentCourse = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.selectedCourse = treatmentCourse;
        
        // Check selected course row
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (self.selectedCourseIndexPath != nil) {
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: self.selectedCourseIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Set selected course index path
        NSUInteger newIndex[] = {0, newRow};
        self.selectedCourseIndexPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    TreatmentCourse *treatmentCourse = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = treatmentCourse.courseName;
    
    cell.accessoryType = (indexPath == self.selectedCourseIndexPath) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TreatmentCourse" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"courseName" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Only show courses that have not been completed
    NSPredicate *attendedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
    [fetchRequest setPredicate:attendedPredicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.courseTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.courseTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.courseTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.courseTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            // Uncheck last selected course row
            if (self.selectedCourseIndexPath != nil) {
                
                NSUInteger lastSelectedIndex[] = {self.selectedCourseIndexPath.section, self.selectedCourseIndexPath.row};
                NSIndexPath *lastSelectedCourseIndexPath = [[NSIndexPath alloc] initWithIndexes:lastSelectedIndex length:2];
                [self configureCell:[tableView cellForRowAtIndexPath:lastSelectedCourseIndexPath] atIndexPath:lastSelectedCourseIndexPath];
            }
            
            // Set added course row index path
            self.selectedCourseIndexPath = newIndexPath;
            
            // Set selected course
            TreatmentCourse *treatmentCourse = [[self fetchedResultsController] objectAtIndexPath:newIndexPath];
            self.selectedCourse = treatmentCourse;
            
            break;
        }
        case NSFetchedResultsChangeDelete: {
            
            if (indexPath == self.selectedCourseIndexPath) {
                
                self.selectedCourseIndexPath = nil;
                self.selectedCourse = nil;
            }
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.courseTableView endUpdates];
}

#pragma mark - Button actions
- (IBAction)addCourseTapped:(id)sender {
    
    if ([self.courseNameTextField.text isEqualToString:@""]) {
        
        [self wobbleView:self.courseNameTextField];
        
    } else {
        
        TreatmentCourse *course = (TreatmentCourse *)[NSEntityDescription insertNewObjectForEntityForName:@"TreatmentCourse" inManagedObjectContext:self.managedObjectContext];
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        course.uniqueId = uuid;
        
        course.courseName = self.courseNameTextField.text;
        course.completed = @NO;
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        self.courseNameTextField.text = @"";
        [self.courseNameTextField resignFirstResponder];
    }
}

- (IBAction)doneTapped:(id)sender {
    
    // Validation
    BOOL isValidated = YES;
    
    if (self.selectedCourse == nil &&
        [TreatmentCourse numberOfTreatmentCourses] == 0) {
        
        isValidated = NO;
        [self wobbleView:self.courseNameTextField];
        
    } else if (self.selectedCourseIndexPath == nil) {
        
        isValidated = NO;
        [self wobbleView:self.courseTableView];
        
    }
    
    if (isValidated) {
        
        [self.delegate courseViewControllerDidFinishWithCourse:self.selectedCourse];
    }
}

#pragma mark - Validation
- (void)wobbleView:(UIView *)viewToWobble {
    
    CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
    wobble.autoreverses = YES;
    wobble.repeatCount = 2.0f;
    wobble.duration = 0.10f;
    [viewToWobble.layer addAnimation:wobble forKey:nil];
}

@end