//
//  CurrencySelectionViewController.m
//  myTeeth
//
//  Created by David Canty on 16/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "CurrencySelectionViewController.h"
#import "Country+Utils.h"
#import "AppDelegate.h"

static NSString *kCurrencyCellIdentifier = @"CurrencyCellIdentifier";

@interface CurrencySelectionViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (copy, nonatomic) NSString *selectedLocaleId;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation CurrencySelectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if ([self.userDefaults objectForKey:@"CountryModelObjectsCreated"] == nil) {
    
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        [[self navigationItem] setRightBarButtonItem:barButton];
        [self.activityIndicator startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self createCountryModelObjects];
        });

    } else {
        
        [self scrollToSelectedCountry];
    }
}

- (void)scrollToSelectedCountry {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.selectedLocaleId = [defaults objectForKey:@"DefaultLocaleId"];
    Country *selectedCountry = [Country countryWithLocale:self.selectedLocaleId];
    NSIndexPath *selectedCountryIndexPath = [self.fetchedResultsController indexPathForObject:selectedCountry];
    [self.tableView scrollToRowAtIndexPath:selectedCountryIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)createCountryModelObjects {
    
    NSString *localesPList = [[NSBundle mainBundle]  pathForResource:@"Locales" ofType:@"plist"];
    NSArray *localeIDs = [[NSArray alloc] initWithContentsOfFile:localesPList];
    
    for (NSString *localeID in localeIDs) {
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: localeID];
        NSString *countryName = [locale displayNameForKey:NSLocaleIdentifier value:localeID];
        NSScanner *countryNameScanner = [NSScanner scannerWithString:countryName];
        NSString *name;
        NSString *language;
        [countryNameScanner scanUpToString:@" (" intoString:&language];
        [countryNameScanner scanString:@"(" intoString:NULL];
        [countryNameScanner scanUpToString:@")" intoString:&name];
        
        NSString *currencyCode = [locale objectForKey:NSLocaleCurrencyCode];
        
        Country *country = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
        [country setCountryName:name];
        [country setCountryLocale:localeID];
        [country setCountryCurrency:currencyCode];
        [country setCountryLanguage:language];
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [country setUniqueId:uuid];

        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            
            NSLog(@"Error saving Country: %@", [error localizedDescription]);
        }
    }

    [self.userDefaults setObject:@"CountryModelObjectsCreated" forKey:@"CountryModelObjectsCreated"];
    [self.userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.tableView reloadData];
        
        [self scrollToSelectedCountry];
        
        [self.activityIndicator stopAnimating];
        [[self navigationItem] setRightBarButtonItem:nil];
    });
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCurrencyCellIdentifier forIndexPath:indexPath];
    
    Country *country = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSString *textLabelString = @"";
    if (country.countryName != nil) {
        
        textLabelString = [NSString stringWithFormat:@"%@ - ", country.countryName];
    }
    
    NSLocale *countryLocale = [[NSLocale alloc] initWithLocaleIdentifier: country.countryLocale];
    NSString *countryCurrencySymbol = [countryLocale objectForKey:NSLocaleCurrencySymbol];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", country.countryCurrency, countryCurrencySymbol];
    
    textLabelString = [textLabelString stringByAppendingString:[NSString stringWithFormat:@"%@", country.countryLanguage]];
    cell.detailTextLabel.text = textLabelString;
    
    cell.accessoryType = ([country.countryLocale isEqualToString:self.selectedLocaleId]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Country *selectedCountry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedLocaleId = selectedCountry.countryLocale;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.selectedLocaleId forKey:@"DefaultLocaleId"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"countryName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *frc =[[NSFetchedResultsController alloc]
                                      initWithFetchRequest:fetchRequest
                                      managedObjectContext:self.managedObjectContext
                                      sectionNameKeyPath:nil
                                      cacheName:nil];
    frc.delegate = self;
    _fetchedResultsController = frc;
    
    return _fetchedResultsController;
}

@end