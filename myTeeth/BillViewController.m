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

@property (weak, nonatomic) IBOutlet UILabel *billAmountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountPaidTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceTitleLabel;


@property (weak, nonatomic) IBOutlet UITextField *billAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *amountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fullyPaidSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *paymentTransactionTextField;
@property (weak, nonatomic) IBOutlet UIButton *addTransactionButton;
@property (weak, nonatomic) IBOutlet UITableView *transactionHistoryTableView;

@property (strong, nonatomic) Bill *bill;
@property (strong, nonatomic) NSMutableArray *paymentTransactions;

@property (strong, nonatomic) NSDecimalNumber *billAmount;
@property (strong, nonatomic) NSDecimalNumber *amountPaid;
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
    
    // Add currency symbol to title labels
    self.billAmountTitleLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      self.billAmountTitleLabel.text,
                                      self.localeCurrencySymbol];
    self.amountPaidTitleLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      self.amountPaidTitleLabel.text,
                                      self.localeCurrencySymbol];
    self.balanceTitleLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      self.balanceTitleLabel.text,
                                      self.localeCurrencySymbol];
    
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
        
        self.billAmount = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:0.0];
        self.paymentTransactionAmountValue = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:0.0];
        self.amountPaid = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:0.0];
        
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
        
        [self disableFields];
    }
}

- (void)disableFields {
    
    self.amountPaidLabel.enabled = NO;
    self.balanceLabel.enabled = NO;
    self.fullyPaidSegmentedControl.enabled = NO;
    self.paymentTransactionTextField.enabled = NO;
    self.addTransactionButton.enabled = NO;
}

- (void)enableFields {
    
    self.amountPaidLabel.enabled = YES;
    self.balanceLabel.enabled = YES;
    self.fullyPaidSegmentedControl.enabled = YES;
    self.paymentTransactionTextField.enabled = YES;
    self.addTransactionButton.enabled = YES;
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
#warning - need to prevent negative balance when changing bill amount to less than it was after fully paid
#warning - need to allow second 0 after decimal separator
#warning - if enter digit then . followed by 0, it deletes .
    
    // Only allow numbers and decimal separator
    NSString *allowedCharacters = [NSString stringWithFormat:@"0123456789%@", self.localeDecimalSeparator];
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:allowedCharacters] invertedSet];
    
    // Format number
    NSString *amountString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    amountString = [[amountString componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
    self.numberFormatter.minimumFractionDigits = 0;
    NSDecimalNumber *amount = (NSDecimalNumber *)[self.numberFormatter numberFromString:amountString];
    
    // Allow backspace
    if (range.length > 0 && string.length == 0) {
        
        if (textField.text.length == 1 ||
            [amount doubleValue] == 0) {
            
            [self disableFields];
        }
        
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
    
    textField.text = [self.numberFormatter stringFromNumber:amount];
    
    if (textField.tag == 2) { // Bill amount text field
        
        if ([amount doubleValue] == 0) {
            
            [self disableFields];
            
        } else {
        
            [self enableFields];
        }
        
        [self updateAmountPaidAndBalance];
        
        return NO;
        
    } else if (textField.tag == 3) { // Payment transaction text field
        
        self.paymentTransactionAmountValue = amount;
        return NO;
    }
    
    return YES;
}

- (void)updateAmountPaidAndBalance {
    
    // We have a bill amount value so update balance
    NSString *billAmountString = self.billAmountTextField.text;
    self.billAmount = [NSDecimalNumber decimalNumberWithString:billAmountString];
    
    NSString *paidAmountString = self.amountPaidLabel.text;
    self.amountPaid = [NSDecimalNumber decimalNumberWithString:paidAmountString];
    
    NSDecimalNumber *balanceAmount = [self.billAmount decimalNumberBySubtracting:self.amountPaid];
    self.numberFormatter.minimumFractionDigits = 2;
    self.balanceLabel.text = [self.numberFormatter stringFromNumber:balanceAmount];
    
    // Check if bill is still paid up
    if ([balanceAmount compare:[NSDecimalNumber zero]] ==  NSOrderedDescending) {
        
        // Set fully paid control to No
        self.fullyPaidSegmentedControl.selectedSegmentIndex = 1;
        
        // Enable fields
        [self enableFields];
        
    } else {
        
        // Set fully paid control to Yes
        self.fullyPaidSegmentedControl.selectedSegmentIndex = 0;
        
        // Disable fields
        [self disableFields];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.billAmountTextField) {
        
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
                
            } else {
                
                // We have a bill amount value so update balance
                [self updateAmountPaidAndBalance];
            }
            
        } else { // Has no decimal separator
            
            if ([textField.text isEqualToString:@""]) {
                
                // If empty, fill with 0
                textField.text = @"0";
            }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Get transaction amount
        PaymentTransaction *transaction = self.paymentTransactions[indexPath.row];
        NSDecimalNumber *transactionAmount = transaction.transactionAmount;
        
        self.numberFormatter.minimumFractionDigits = 2;
        
        // Update amount paid
        self.amountPaid = [self.amountPaid decimalNumberBySubtracting:transactionAmount];
        self.amountPaidLabel.text = [self.numberFormatter stringFromNumber:self.amountPaid];
        
        // Update balance
        self.billAmount = [NSDecimalNumber decimalNumberWithDecimal:[self.billAmount decimalValue]];
        NSDecimalNumber *balance = [self.billAmount decimalNumberBySubtracting:self.amountPaid];
        self.balanceLabel.text = [self.numberFormatter stringFromNumber:balance];
        
        // Set fully paid control to No
        self.fullyPaidSegmentedControl.selectedSegmentIndex = 1;
        
        // Enable fields
        [self enableFields];
        
        // Delete transaction and reload table view
        [self.paymentTransactions removeObjectAtIndex:indexPath.row];
        [self.transactionHistoryTableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentTransactionCellIdentifier];
    
    PaymentTransaction *paymentTransaction = self.paymentTransactions[indexPath.row];
    
    // Transaction amount
    NSNumberFormatter *transactionNumberFormatter = [[NSNumberFormatter alloc] init];
    transactionNumberFormatter.locale = self.defaultsLocale;
    transactionNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    transactionNumberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    transactionNumberFormatter.usesGroupingSeparator = YES;
    transactionNumberFormatter.maximumFractionDigits = 2;
    transactionNumberFormatter.minimumFractionDigits = 2;
    cell.textLabel.text = [transactionNumberFormatter stringFromNumber:paymentTransaction.transactionAmount];
    
    // Transaction date
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [outputDateFormatter setDateFormat:@"eeee d MMM yyyy 'at' h:mm a"];
    
    NSString *localizedDateString = [NSDateFormatter localizedStringFromDate:paymentTransaction.transactionDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    
    cell.detailTextLabel.text = localizedDateString;
    
    return cell;
}

#pragma mark - Button actions
- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender {

    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        
        // Create transaction for full amount or to make up to fully paid
        NSString *billAmountString = self.billAmountTextField.text;
        self.billAmount = [NSDecimalNumber decimalNumberWithString:billAmountString];
        
        // Calculate balance to pay
        NSString *paidAmountString = self.amountPaidLabel.text;
        self.amountPaid = [NSDecimalNumber decimalNumberWithString:paidAmountString];
        
        NSDecimalNumber *balanceAmount = [self.billAmount decimalNumberBySubtracting:self.amountPaid];
        
        if ([balanceAmount compare:[NSDecimalNumber zero]] ==  NSOrderedDescending) {
            
            // Add transaction
            [self addPaymentTransactionForAmount:balanceAmount];
            
            // Set amount paid label
            self.numberFormatter.minimumFractionDigits = 2;
            self.amountPaidLabel.text = [self.numberFormatter stringFromNumber:self.billAmount];
            
            // Set balance label
            if (![self.localeDecimalSeparator isEqualToString:@""]) { // Has a decimal separator
                
                self.balanceLabel.text = [self.numberFormatter stringFromNumber:@0];
                
            } else {
                
                self.balanceLabel.text = @"0";
            }
        }
        
        // Disable fields
        [self disableFields];
        [self.billAmountTextField resignFirstResponder];
        [self.paymentTransactionTextField resignFirstResponder];
        
    } else {
        
        [self enableFields];
    }
}

- (void)addPaymentTransactionForAmount:(NSDecimalNumber *)transactionAmount {
    
    PaymentTransaction *paymentTransaction = (PaymentTransaction *)[NSEntityDescription insertNewObjectForEntityForName:@"PaymentTransaction" inManagedObjectContext:self.managedObjectContext];
    
    // Unique id
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [paymentTransaction setUniqueId:uuid];
    
    // Transaction amount
    paymentTransaction.transactionAmount = transactionAmount;
    
    // Transaction date
    paymentTransaction.transactionDate = [NSDate date];
    
    // Bill
    paymentTransaction.bill = self.bill;
    
    // Add transaction to working array and reload transaction history table
    [self.paymentTransactions addObject:paymentTransaction];
    [self.transactionHistoryTableView reloadData];
    
    // Update amount paid
    self.amountPaid = [self.amountPaid decimalNumberByAdding:transactionAmount];
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