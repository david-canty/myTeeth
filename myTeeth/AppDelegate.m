//
//  AppDelegate.m
//  myTeeth
//
//  Created by Dave on 08/10/2013.
//  Copyright (c) 2013 David Canty. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MainViewController.h"
#import "ServiceProvider+Utils.h"
#import "PaymentType+Utils.h"
#import "PaymentMethod+Utils.h"
#import "JobTitle+Utils.h"
#import "Salutation+Utils.h"
#import "TraitOverrideViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//        splitViewController.delegate = (id)navigationController.topViewController;
//        
//        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
//        MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
//        controller.managedObjectContext = self.managedObjectContext;
//        controller.persistentStoreCoordinator = self.persistentStoreCoordinator;
//    }
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    TraitOverrideViewController *traitController = [[TraitOverrideViewController alloc] init];
    traitController.viewController = splitViewController;
    self.window.rootViewController = traitController;
    
    UINavigationController *mainNavigationController = splitViewController.viewControllers[0];
    MasterViewController *controller = (MasterViewController *)mainNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    controller.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    // Load service providers, payment types, payment methods, job titles, and salutations
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([ServiceProvider numberOfServiceProviders] == 0) {
            [ServiceProvider loadServiceProviders];
        }
        if ([PaymentType numberOfPaymentTypes] == 0) {
            [PaymentType loadPaymentTypes];
        }
        if ([PaymentMethod numberOfPaymentMethods] == 0) {
            [PaymentMethod loadPaymentMethods];
        }
        if ([JobTitle numberOfJobTitles] == 0) {
            [JobTitle loadJobTitles];
        }
        if ([Salutation numberOfSalutations] == 0) {
            [Salutation loadSalutations];
        }
    });
    
    // Register default locale id
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{@"DefaultLocaleId" : @"en_GB"}];
    
    return YES;
}

#pragma mark - Split view
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]]) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Request access to Event Store for appointments and checkup reminders (user might have granted or denied access in Settings)
    self.eventStore = [[EKEventStore alloc] init];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,
                                                                              NSError *error) {
        
        if (granted) {
            
            NSLog(@"Access to Event Store granted");
            
        } else {
            
            NSLog(@"Access to Event Store not granted");
        }
        
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"myTeeth" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"myTeeth.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end