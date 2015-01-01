//
//  SettingsViewController.m
//  myTeeth
//
//  Created by David Canty on 22/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "SettingsViewController.h"
#import "CurrencySelectionViewController.h"
#import "Country+Utils.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currencyDetailLabel;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Display selected currency
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedLocaleId = [defaults objectForKey:@"DefaultLocaleId"];
    Country *selectedCountry = [Country countryWithLocale:selectedLocaleId];
    self.currencyDetailLabel.text = [NSString stringWithFormat:@"%@ (%@) (%@)",
                                     selectedCountry.countryName,
                                     selectedCountry.countryLanguage,
                                     selectedCountry.countryCurrency];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowCurrencyList"]) {
        
        CurrencySelectionViewController *controller = (CurrencySelectionViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Select Currency", @"Select Currency");
    }
}

#pragma mark - Button actions
- (IBAction)doneButtonTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end