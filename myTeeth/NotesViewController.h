//
//  NotesViewController.h
//  myTeeth
//
//  Created by Dave on 13/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NoteDetailViewController.h"

@class NoteDetailViewController;

@interface NotesViewController : UITableViewController <NSFetchedResultsControllerDelegate, NoteDetailViewControllerDelegate>

@property (strong, nonatomic) NoteDetailViewController *noteDetailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end