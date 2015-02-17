//
//  BillViewController.m
//  myTeeth
//
//  Created by David Canty on 14/12/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "BillViewController.h"
#import "PaymentTransaction.h"

static NSString *paymentTransactionCellIdentifier = @"PaymentTransactionCellIdentifier";

@interface BillViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *billAmountTextField;

@property (weak, nonatomic) IBOutlet UILabel *billAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *fullyPaidSegmentedControl;

@property (weak, nonatomic) IBOutlet UITextField *paymentTransactionTextField;
@property (weak, nonatomic) IBOutlet UIButton *addTransactionButton;
@property (weak, nonatomic) IBOutlet UITableView *transactionHistoryTableView;

@property (strong, nonatomic) NSMutableArray *paymentTransactions;

@property (strong, nonatomic) NSDecimalNumber *billAmount;
@property (assign, nonatomic) BOOL isFullyPaid;

@property (strong, nonatomic) NSLocale *defaultsLocale;
@property (strong, nonatomic) NSNumberFormatter *decimalNumberFormatter;
@property (strong, nonatomic) NSNumberFormatter *currencyNumberFormatter;
@property (copy, nonatomic) NSString *decimalSeparator;

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
    
    // Set up decimal number formatter
    self.decimalNumberFormatter = [[NSNumberFormatter alloc] init];
    self.decimalNumberFormatter.locale = self.defaultsLocale;
    self.decimalNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.decimalNumberFormatter.maximumFractionDigits = 2;
    self.decimalNumberFormatter.minimumFractionDigits = 2;
    self.decimalNumberFormatter.usesGroupingSeparator = NO;
    self.decimalNumberFormatter.lenient = YES;
    self.decimalNumberFormatter.generatesDecimalNumbers = YES;
    
    // Set up currency number formatter
    self.currencyNumberFormatter = [[NSNumberFormatter alloc] init];
    self.currencyNumberFormatter.locale = self.defaultsLocale;
    self.currencyNumberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.currencyNumberFormatter.maximumFractionDigits = 2;
    self.currencyNumberFormatter.minimumFractionDigits = 2;
    self.currencyNumberFormatter.usesGroupingSeparator = YES;
    self.currencyNumberFormatter.lenient = YES;
    self.currencyNumberFormatter.generatesDecimalNumbers = YES;
    
    // Ensure decimal separator has a value
    if (self.decimalNumberFormatter.decimalSeparator != nil) {
        
        self.decimalSeparator = self.decimalNumberFormatter.decimalSeparator;
        
    } else {
        
        self.decimalSeparator = @""; // e.g., Japanese YEN
    }
    
    self.isFullyPaid = NO;
    
    if (self.bill) {
        
        // Set bill amount
        self.billAmount = self.bill.billAmount;
        
        // Set bill amount text field
        self.billAmountTextField.text = [self.billAmount stringValue];
        [self checkFractionZerosForTextField:self.billAmountTextField];
        
        // Set payment transaction text field
        [self updateDecimalTextField:self.paymentTransactionTextField withString:@""];
        
        // Set transactions
        for (PaymentTransaction *paymentTransaction in self.bill.paymentTransactions) {
            
            [self.paymentTransactions addObject:paymentTransaction];
        }
        
        // Set label values
        [self updateCurrencyLabel:self.billAmountLabel withString:self.billAmountTextField.text];
        [self updateAmountPaidAndBalance];
        
    } else {
        
        self.bill = (Bill *)[NSEntityDescription insertNewObjectForEntityForName:@"Bill" inManagedObjectContext:self.managedObjectContext];
        
        self.billAmount = [NSDecimalNumber zero];
        
        [self updateDecimalTextField:self.billAmountTextField withString:@""];
        [self updateDecimalTextField:self.paymentTransactionTextField withString:@""];
        
        [self updateCurrencyLabel:self.billAmountLabel withString:@""];
        [self updateCurrencyLabel:self.amountPaidLabel withString:@""];
        [self updateCurrencyLabel:self.balanceLabel withString:@""];
        
        [self disableFields];
    }
    
    [self.billAmountTextField addTarget:self
                                 action:@selector(textFieldDidChange:)
                       forControlEvents:UIControlEventEditingChanged];
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

- (void)checkFractionZerosForTextField:(UITextField *)textField {
    
    NSString *amountString = textField.text;
    
    if ([amountString isEqualToString:@""]) {
        
        //textfield.text = [self.decimalNumberFormatter stringFromNumber:@0];
        
    } else {
        
        NSDictionary *localeDict = [NSDictionary dictionaryWithObject:self.decimalSeparator forKey:NSLocaleDecimalSeparator];
        NSDecimalNumber *amountNumber = [NSDecimalNumber decimalNumberWithString:amountString locale:localeDict];
        NSString *formattedAmountString = [self.decimalNumberFormatter stringFromNumber:amountNumber];
        textField.text = formattedAmountString;
    }
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == self.billAmountTextField) {
        
        [self checkFractionZerosForTextField:self.billAmountTextField];
        [self updateCurrencyLabel:self.billAmountLabel withString:textField.text];
        [self updateAmountPaidAndBalance];
        
    } else {
        
        [self checkFractionZerosForTextField:self.paymentTransactionTextField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.billAmountTextField) {
        
        [self checkFractionZerosForTextField:self.billAmountTextField];
        [self updateCurrencyLabel:self.billAmountLabel withString:textField.text];
        [self updateAmountPaidAndBalance];
        
    } else if (textField == self.paymentTransactionTextField) {
        
        [self checkFractionZerosForTextField:self.paymentTransactionTextField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Decimal separator should not be first
    if (range.location == 0 && [string isEqualToString:self.decimalSeparator]) {
        
        return NO;
    }
    
    // Allow a single decimal separator and 2 fraction digits
    NSRange decimalSeparatorRange = [textField.text rangeOfString:self.decimalSeparator];
    if (decimalSeparatorRange.location != NSNotFound) {
        
        if ([string isEqualToString:self.decimalSeparator] ||
            range.location > (decimalSeparatorRange.location + 2)) {
            
            return NO;
        }
    }
    
    // Prevent more that one zero at start
    if (range.location == 1 &&
        [string isEqualToString:@"0"] &&
        [[textField.text substringToIndex:1] isEqualToString:@"0"]) {
        
        return NO;
    }
    
    // Enable backspace
    if (range.length > 0 && [string length] == 0) {
        
        // Remove last character from text field
        NSString *newString = [textField.text substringToIndex:textField.text.length - 1];
        
        if (textField.tag == 2) { // Bill amount text field
            
            // Update bill amount label
            [self updateCurrencyLabel:self.billAmountLabel withString:newString];

        } else if (textField.tag == 3) { // Transaction amount text field
        
            
        }
        
        return YES;
    }
    
    // Allowed characters
    NSString *allowedCharacters = [NSString stringWithFormat:@"0123456789%@", self.decimalSeparator];
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:allowedCharacters] invertedSet];
    
    // Check string is allowed
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:characterSet];
    if (trimmedString.length > 0) {
        
        if (textField.tag == 2) { // Bill amount text field
            
            // Update bill amount label
            NSString *newString = [textField.text stringByAppendingString:trimmedString];
            [self updateCurrencyLabel:self.billAmountLabel withString:newString];
            
        }  else if (textField.tag == 3) { // Transaction amount text field
            
            
        }
        
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField == self.billAmountTextField) {
        
        [self updateAmountPaidAndBalance];
    }
}

- (void)updateAmountPaidAndBalance {
    
    // Update bill amount
    self.billAmount = [NSDecimalNumber decimalNumberWithString:self.billAmountTextField.text];
    
    // If bill amount is NaN, set to zero
    if ([self.billAmount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        
        self.billAmount = [NSDecimalNumber zero];
    }
    
    // Update amount paid label
    NSDecimalNumber *amountPaid = [self.bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
    [self updateCurrencyLabel:self.amountPaidLabel withString:[amountPaid stringValue]];
    
    // Update balance label
    NSDecimalNumber *balance = [self.billAmount decimalNumberBySubtracting:amountPaid];
    [self updateCurrencyLabel:self.balanceLabel withString:[balance stringValue]];
    
    // Check if bill is paid up
    if (self.isFullyPaid) {
        
        // Disable fields
        [self disableFields];
        
    } else if ([balance compare:[NSDecimalNumber zero]] ==  NSOrderedSame) {
        
        // Set fully paid control to No
        self.fullyPaidSegmentedControl.selectedSegmentIndex = 1;
        
        // Disable fields
        [self disableFields];
        
    } else if ([balance compare:[NSDecimalNumber zero]] ==  NSOrderedDescending) {
        
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
        
        // Delete transaction and reload table view
        PaymentTransaction *transaction = self.paymentTransactions[indexPath.row];
        
        [self.managedObjectContext deleteObject:transaction];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.paymentTransactions removeObject:transaction];
        [self.transactionHistoryTableView reloadData];
        
        self.isFullyPaid = NO;
        
        [self.billAmountTextField resignFirstResponder];
        [self.paymentTransactionTextField resignFirstResponder];
        
        // Update amound paid and balance
        [self updateAmountPaidAndBalance];
        
        // Enable bill amount field if no transactions
        NSDecimalNumber *amountPaid = [self.bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
        if ([amountPaid isEqualToNumber:[NSDecimalNumber zero]]) {
            
            self.billAmountTextField.enabled = YES;
        }
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

#pragma mark - Update number labels
- (void)updateCurrencyLabel:(UILabel *)label withString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {
        
        label.text = [self.currencyNumberFormatter stringFromNumber:@0];
        
    } else {
        
        NSDictionary *localeDict = [NSDictionary dictionaryWithObject:self.decimalSeparator forKey:NSLocaleDecimalSeparator];
        NSDecimalNumber *amountNumber = [NSDecimalNumber decimalNumberWithString:string locale:localeDict];
        NSString *formattedAmountString = [self.currencyNumberFormatter stringFromNumber:amountNumber];
        label.text = formattedAmountString;
    }
    
    // Disable fields if bill amount is 0
    if (label == self.billAmountLabel) {
        
        NSDictionary *localeDict = [NSDictionary dictionaryWithObject:self.decimalSeparator forKey:NSLocaleDecimalSeparator];
        NSDecimalNumber *amountNumber = [NSDecimalNumber decimalNumberWithString:string locale:localeDict];
        
        if ([amountNumber isEqualToNumber:[NSDecimalNumber notANumber]] ||
            [amountNumber isEqualToNumber:@0]) {
            
            [self disableFields];
            
        } else {
            
            [self enableFields];
        }
    }

}

#pragma mark - Update number text fields
- (void)updateDecimalTextField:(UITextField *)textField withString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {
        
        textField.text = [self.decimalNumberFormatter stringFromNumber:@0];
        
    } else {
        
        NSDictionary *localeDict = [NSDictionary dictionaryWithObject:self.decimalSeparator forKey:NSLocaleDecimalSeparator];
        NSDecimalNumber *amountNumber = [NSDecimalNumber decimalNumberWithString:string locale:localeDict];
        NSString *formattedAmountString = [self.decimalNumberFormatter stringFromNumber:amountNumber];
        textField.text = formattedAmountString;
    }
}

#pragma mark - Button actions
- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender {

    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        
        self.isFullyPaid = YES;
        self.billAmountTextField.enabled = NO;
        
        // Bill amount
        self.billAmount = [NSDecimalNumber decimalNumberWithString:self.billAmountTextField.text];
        
        // Amount paid
        NSDecimalNumber *amountPaid = [self.bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
        
        // Balance = bill amount - amount paid
        NSDecimalNumber *balance = [self.billAmount decimalNumberBySubtracting:amountPaid];
        
        // Create transaction for balance
        [self addPaymentTransactionForAmount:balance];

        // Update amount paid and balance
        [self updateAmountPaidAndBalance];
        
        [self.billAmountTextField resignFirstResponder];
        [self.paymentTransactionTextField resignFirstResponder];
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
    
    // Set transaction bill
    paymentTransaction.bill = self.bill;
    
    // Add transaction to working array and reload transaction history table
    [self.paymentTransactions addObject:paymentTransaction];
    [self.transactionHistoryTableView reloadData];
}

- (IBAction)addTransactionTapped:(id)sender {
    
    // Amount paid
    NSDecimalNumber *amountPaid = [self.bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
    
    // Balance = bill amount - amount paid
    NSDecimalNumber *balance = [self.billAmount decimalNumberBySubtracting:amountPaid];

    // Check transaction amount is <= balance
    NSDecimalNumber *transactionAmount = [NSDecimalNumber decimalNumberWithString:self.paymentTransactionTextField.text];
    
    if (![transactionAmount isEqualToNumber:[NSDecimalNumber zero]]) {
        
        if ([transactionAmount compare:balance] == NSOrderedAscending ||
            [transactionAmount compare:balance] == NSOrderedSame) {
            
            [self addPaymentTransactionForAmount:transactionAmount];
            
            [self.paymentTransactionTextField resignFirstResponder];
            [self updateDecimalTextField:self.paymentTransactionTextField withString:@""];
            [self updateAmountPaidAndBalance];
            
            // Disable bill amount field to prevent negative balances
            self.billAmountTextField.enabled = NO;
            
            // Check if balance is zero
            NSDecimalNumber *amountPaid = [self.bill.paymentTransactions valueForKeyPath:@"@sum.transactionAmount"];
            NSDecimalNumber *balance = [self.billAmount decimalNumberBySubtracting:amountPaid];
            if ([balance isEqualToNumber:[NSDecimalNumber zero]]) {
                
                // Set fully paid control to Yes
                self.fullyPaidSegmentedControl.selectedSegmentIndex = 0;
                
                // Disable fields
                [self disableFields];
            }
            
        } else {
            
            [self wobbleView:self.balanceLabel];
            [self wobbleView:self.paymentTransactionTextField];
        }
        
    } else {
        
        [self checkFractionZerosForTextField:self.paymentTransactionTextField];
        [self wobbleView:self.paymentTransactionTextField];
    }
}

- (IBAction)cancelTapped:(id)sender {
    
    if (self.paymentTransactions.count > 0) {
        
        // Remove any payment transactions
        for (PaymentTransaction *paymentTransaction in self.paymentTransactions) {
            
            [self.managedObjectContext deleteObject:paymentTransaction];
        }
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [self.delegate billViewControllerDidCancel];
}

- (IBAction)doneTapped:(id)sender {
    
    BOOL isValidated = YES;
    
    // Validate fields
    if ([self.billAmount isEqualToNumber:[NSDecimalNumber zero]]) {
        
        [self wobbleView:self.billAmountTextField];
        isValidated = NO;
    }
    
    if (isValidated) {
        
        if (self.bill.uniqueId == nil) {
            
            // Unique id
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [self.bill setUniqueId:uuid];
        }
        
        // Bill amount
        self.bill.billAmount = self.billAmount;
        
        // Payment transactions
        for (PaymentTransaction *paymentTransaction in self.bill.paymentTransactions) {
            
            [self.managedObjectContext deleteObject:paymentTransaction];  // Remove existing
        }
        
        for (PaymentTransaction *paymentTransaction in self.paymentTransactions) {
            
            [self.bill addPaymentTransactionsObject:paymentTransaction]; // Add new
        }
        
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