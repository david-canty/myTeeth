//
//  BillViewController.m
//  myTeeth
//
//  Created by David Canty on 14/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "BillViewController.h"
#import "Bill.h"
#import "PaymentTransaction.h"

static NSString *paymentTransactionCellIdentifier = @"PaymentTransactionCellIdentifier";

@interface BillViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *billAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *amountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fullyPaidSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *paymentTransactionTextField;
@property (weak, nonatomic) IBOutlet UITableView *transactionHistoryTableView;

@property (strong, nonatomic) Bill *bill;
@property (strong, nonatomic) NSMutableArray *paymentTransactions;

@property (strong, nonatomic) NSDecimalNumber *billAmountValue;
@property (strong, nonatomic) NSDecimalNumber *paymentTransactionAmountValue;

@property (strong, nonatomic) NSLocale *defaultsLocale;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (copy, nonatomic) NSString *localeDecimalSeparator;
@property (copy, nonatomic) NSString *localeCurrencySymbol;

- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender;
- (IBAction)addTransactionTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation BillViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.paymentTransactions = [@[] mutableCopy];
    
    // Get default locale from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.defaultsLocale = [NSLocale localeWithLocaleIdentifier:[defaults objectForKey:@"DefaultLocaleId"]];
    
    // Set up number formatter and get decimal separator
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.locale = self.defaultsLocale;
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    self.numberFormatter.usesGroupingSeparator = YES;
    self.numberFormatter.maximumFractionDigits = 2;
    self.numberFormatter.minimumFractionDigits = 0;
    self.localeCurrencySymbol = self.numberFormatter.currencySymbol;
    
    // Ensure decimal separator has a value
    if (self.numberFormatter.decimalSeparator != nil) {
        
        self.localeDecimalSeparator = self.numberFormatter.decimalSeparator;
        
    } else {
        
        self.localeDecimalSeparator = @""; // e.g., Japanese YEN
    }

    
    if (self.editingBill) {
        
        self.bill = self.editingBill;
        
        
    } else {
        
        self.bill = (Bill *)[NSEntityDescription insertNewObjectForEntityForName:@"Bill" inManagedObjectContext:self.managedObjectContext];
        
        self.billAmountValue = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:0];
        self.paymentTransactionAmountValue = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:0];
        
        if (![self.localeDecimalSeparator isEqualToString:@""]) { // Has a decimal separator
            
            NSString *zeroString = [NSString stringWithFormat:@"0%@00", self.localeDecimalSeparator];
            
            self.billAmountTextField.text = zeroString;
            self.paymentTransactionTextField.text = zeroString;
            self.amountPaidLabel.text = zeroString;
            self.balanceLabel.text = zeroString;
            
        } else {
         
            self.billAmountTextField.text = @"0";
            self.paymentTransactionTextField.text = @"0";
            self.amountPaidLabel.text = @"0";
            self.balanceLabel.text = @"0";
        }
    }
}

#pragma mark - Text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow backspace
    if (range.length > 0 && string.length == 0) {
        
        return YES;
    }
    
    // Prevent more than decimal separator
    if ([string isEqualToString:self.localeDecimalSeparator]) {
        
        NSArray *arrayOfStrings = [textField.text componentsSeparatedByString:self.localeDecimalSeparator];
        if ([arrayOfStrings count] > 1) {
            
            return NO;
        }
        
        // Allow first decimal separator
        return YES;
    }
    
    // Only allow numbers and decimal separator
    NSString *allowedCharacters = [NSString stringWithFormat:@"0123456789%@", self.localeDecimalSeparator];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:allowedCharacters] invertedSet];
    
    // Format number
    NSString *amountString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    amountString = [[amountString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
    self.numberFormatter.minimumFractionDigits = 0;
    NSDecimalNumber *amount = (NSDecimalNumber *)[self.numberFormatter numberFromString:amountString];
    textField.text = [self.numberFormatter stringFromNumber:amount];
    
    if (textField.tag == 2) { // Bill amount text field
        
        self.billAmountValue = amount;
        return NO;
        
    } else if (textField.tag == 3) { // Payment transaction text field
        
        self.paymentTransactionAmountValue = amount;
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
        
    if (![self.localeDecimalSeparator isEqualToString:@""]) { // Has a decimal separator
        
        if ([textField.text isEqualToString:@""]) {
            
            // If empty, fill with 0.00
            textField.text = [NSString stringWithFormat:@"0%@00", self.localeDecimalSeparator];
            
        } else if ([[textField.text substringFromIndex:textField.text.length - 1] isEqualToString:self.localeDecimalSeparator]) {
            
            // If amount value has a decimal point at end, add 00
            textField.text = [NSString stringWithFormat:@"%@00", textField.text];
            
        } else if (![textField.text containsString:self.localeDecimalSeparator]) {
            
            // If amount has no decimal point, add .00
            textField.text = [NSString stringWithFormat:@"%@%@00", textField.text, self.localeDecimalSeparator];
            
        } else if ([[textField.text substringWithRange:NSMakeRange(textField.text.length - 2, 1)] isEqualToString:self.localeDecimalSeparator]) {
            
            // If amount has a decimal point followed by a single digit, add another 0
            textField.text = [NSString stringWithFormat:@"%@0", textField.text];
        }
        
    } else { // Has no decimal separator
        
        if ([textField.text isEqualToString:@""]) {
            
            // If empty, fill with 0
            textField.text = @"0";
        }
    }
    
    return YES;
}

#pragma mark - Transaction History table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return [self.paymentTransactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentTransactionCellIdentifier];
    
    PaymentTransaction *paymentTransaction = self.paymentTransactions[indexPath.row];
    
    
    
    return cell;
}

#pragma mark - Button actions
- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender {
    
    //if bill amount > 0
    
    // Create transaction for full amount
    NSString *billAmountString = self.billAmountTextField.text;
    
    NSNumberFormatter *billAmountNumberFormatter = [[NSNumberFormatter alloc] init];
    billAmountNumberFormatter.locale = self.defaultsLocale;
    billAmountNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    billAmountNumberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    billAmountNumberFormatter.usesGroupingSeparator = YES;
    billAmountNumberFormatter.maximumFractionDigits = 2;
    billAmountNumberFormatter.minimumFractionDigits = 2;
    
    NSDecimalNumber *billAmountNumber = (NSDecimalNumber *)[billAmountNumberFormatter numberFromString:billAmountString];
    
    billAmountNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.amountPaidLabel.text = [billAmountNumberFormatter stringFromNumber:billAmountNumber];
}

- (IBAction)addTransactionTapped:(id)sender {
    
    
}

- (IBAction)cancelTapped:(id)sender {
    
    [self.managedObjectContext rollback];
    [self.delegate billViewControllerDidCancel];
}

- (IBAction)doneTapped:(id)sender {
    
    BOOL isValidated = YES;
    
    // Validate fields
    
    
    if (isValidated) {
        
        // Unique id
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [self.bill setUniqueId:uuid];
        
        // Bill amount
        
        
        // Amount paid
        
        
        // Is paid
        
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.delegate billViewControllerDidFinishWithBill:self.bill];
    }
}

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