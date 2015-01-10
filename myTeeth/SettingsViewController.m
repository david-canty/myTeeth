//
//  SettingsViewController.m
//  myTeeth
//
//  Created by David Canty on 22/11/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "SettingsViewController.h"
#import "CurrencySelectionViewController.h"
#import "InfoViewController.h"
#import "Constants.h"

static NSUInteger kContactTableRow = 2;

@interface SettingsViewController () <MFMailComposeViewControllerDelegate>

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
    
    NSLocale *selectedLocale = [NSLocale localeWithLocaleIdentifier:selectedLocaleId];
    NSString *currencyString = [selectedLocale objectForKey:NSLocaleCurrencyCode];
    NSString *currencySymbol = [selectedLocale objectForKey:NSLocaleCurrencySymbol];
    
    self.currencyDetailLabel.text = [NSString stringWithFormat:@"%@ %@",
                                     currencyString,
                                     currencySymbol];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowCurrencyList"]) {
        
        CurrencySelectionViewController *controller = (CurrencySelectionViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Select Currency", @"Select Currency");
    }
    
    if ([[segue identifier] isEqualToString:@"ShowInfoView"]) {
        
        InfoViewController *controller = (InfoViewController *)[segue destinationViewController];
        controller.navigationItem.title = NSLocalizedString(@"Info", @"Info");
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == kContactTableRow) {
        
        [self composeMail];
    }
}

#pragma mark - Contact email
- (void)composeMail {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:kAppVersion];
        //[mc setToRecipients:[NSArray arrayWithObjects:@"support@ddijitall.co.uk", nil]];
        [mc setToRecipients:@[@"david.canty@me.com"]];
        [self presentViewController:mc animated:YES completion:nil];
        
    } else {
        
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:@""
                                                                                  message:@"This device is unable to send email."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:nil];
        [emailAlert addAction:okAction];
        
        [self presentViewController:emailAlert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled: {
            
            break;
        }
        case MFMailComposeResultSaved: {
            
            break;
        }
        case MFMailComposeResultSent: {
            
            break;
        }
        case MFMailComposeResultFailed: {
            
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Button actions
- (IBAction)doneButtonTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end