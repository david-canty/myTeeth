//
//  MainViewController.m
//  myTeeth
//
//  Created by Dave on 08/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import "MainViewController.h"
#import "NotesViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showNotesViewController"]) {
        NotesViewController *notesVC = [segue destinationViewController];
        notesVC.managedObjectContext = self.managedObjectContext;
    }
}

@end
