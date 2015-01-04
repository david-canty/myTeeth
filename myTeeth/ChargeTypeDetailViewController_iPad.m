//
//  ChargeTypeDetailViewController_iPad.m
//  myTeeth
//
//  Created by David Canty on 28/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeTypeDetailViewController_iPad.h"
#import "SingleSelectionListViewController.h"
#import "ChargeType+Utils.h"
#import "ServiceProvider+Utils.h"
#import "PaymentType+Utils.h"
#import "PaymentMethod+Utils.h"
#import "ChargeTypeNameCell.h"
#import "ChargeTypeAmountCell.h"
#import "Constants.h"

static NSString *kChargeTypeCellIdentifier          = @"ChargeTypeCellIdentifier";
static NSString *kChargeTypeNameCellIdentifier      = @"ChargeTypeNameCellIdentifier";
static NSString *kChargeTypeAmountCellIdentifier    = @"ChargeTypeAmountCellIdentifier";

static NSString *kPayPerAppointment                 = @"Pay per Appointment";
static NSString *kPayPerCourseOfTreatment           = @"Pay per Course of Treatment";
static NSString *kExempt                            = @"None (Exempt)";

static NSUInteger const kChargeTypeNameRow  = 0;
static NSUInteger const kServiceProviderRow = 1;
static NSUInteger const kPaymentTypeRow     = 2;
static NSUInteger const kPaymentMethodRow   = 3;
static NSUInteger const kPaymentAmountRow   = 4;

@interface ChargeTypeDetailViewController_iPad () <UITableViewDataSource, UITableViewDelegate, SingleSelectionListViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tableRowData;

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *amountTextField;
@property (strong, nonatomic) NSDecimalNumber *amountValue;

@property (strong, nonatomic) NSLocale *defaultsLocale;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (copy, nonatomic) NSString *localeDecimalSeparator;
@property (copy, nonatomic) NSString *localeCurrencySymbol;

@property (strong, nonatomic) NSArray *serviceProviderDetails;
@property (strong, nonatomic) NSArray *serviceProviderListItems;
@property (strong, nonatomic) NSDictionary *selectedServiceProvider;

@property (strong, nonatomic) NSArray *paymentTypeDetails;
@property (strong, nonatomic) NSArray *paymentTypeListItems;
@property (strong, nonatomic) NSArray *filteredPaymentTypeListItems;
@property (strong, nonatomic) NSDictionary *selectedPaymentType;

@property (strong, nonatomic) NSArray *paymentMethodDetails;
@property (strong, nonatomic) NSArray *paymentMethodListItems;
@property (strong, nonatomic) NSArray *filteredPaymentMethodListItems;
@property (strong, nonatomic) NSDictionary *selectedPaymentMethod;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation ChargeTypeDetailViewController_iPad

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up table row content
    self.tableRowData = @[[@{@"rowTitleString" : @"Name",
                             @"rowDetailString" : @""} mutableCopy],
                          [@{@"rowTitleString" : @"Service Provider",
                             @"rowDetailString" : @"Please select"} mutableCopy],
                          [@{@"rowTitleString" : @"Payment Type",
                             @"rowDetailString" : @"Please select"} mutableCopy],
                          [@{@"rowTitleString" : @"Payment Method",
                             @"rowDetailString" : @"Please select"} mutableCopy],
                          [@{@"rowTitleString" : @"Amount",
                             @"rowDetailString" : @"None"} mutableCopy]];
    
    [self loadServiceProviderDetails];
    [self loadServiceProviderListItems];
    [self loadPaymentTypeDetails];
    [self loadPaymentTypeListItems];
    [self loadPaymentMethodDetails];
    [self loadPaymentMethodListItems];
    
    // If editing, pre-populate fields
    if (self.editingChargeType) {
        
        // Name
        NSMutableDictionary *typeNameTableRowDict = self.tableRowData[kChargeTypeNameRow];
        typeNameTableRowDict[@"rowDetailString"] = self.editingChargeType.typeName;
        
        // Service provider
        self.selectedServiceProvider = @{@"displayName" : self.editingChargeType.serviceProvider.providerName,
                                    @"uniqueId" : self.editingChargeType.serviceProvider.uniqueId};
        NSMutableDictionary *serviceProviderTableRowDict = self.tableRowData[kServiceProviderRow];
        serviceProviderTableRowDict[@"rowDetailString"] = self.selectedServiceProvider[@"displayName"];
        [self filterRelatedPaymentTypesBySelectedServiceProvider];
        
        // Payment type
        self.selectedPaymentType = @{@"displayName" : self.editingChargeType.paymentType.typeName,
                                         @"uniqueId" : self.editingChargeType.paymentType.uniqueId};
        NSMutableDictionary *paymentTypeTableRowDict = self.tableRowData[kPaymentTypeRow];
        paymentTypeTableRowDict[@"rowDetailString"] = self.selectedPaymentType[@"displayName"];
        [self filterRelatedPaymentMethodsBySelectedPaymentType];
        
        // Payment method
        self.selectedPaymentMethod = @{@"displayName" : self.editingChargeType.paymentMethod.methodName,
                                     @"uniqueId" : self.editingChargeType.paymentMethod.uniqueId};
        NSMutableDictionary *paymentMethodTableRowDict = self.tableRowData[kPaymentMethodRow];
        paymentMethodTableRowDict[@"rowDetailString"] = self.selectedPaymentMethod[@"displayName"];
        
        // Amount
        NSDecimalNumber *amountValue = [[NSDecimalNumber alloc] init];
        amountValue = self.editingChargeType.regularAmount;
        self.amountValue = amountValue;
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Persist name text between view transitions
    NSMutableDictionary *typeNameTableRowDict = self.tableRowData[kChargeTypeNameRow];
    typeNameTableRowDict[@"rowDetailString"] = self.nameTextField.text;
    [self.nameTextField resignFirstResponder];
    
    if (self.amountTextField) {
        
        [self.amountTextField resignFirstResponder];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Keyboard notification handlers
- (void)keyboardWillShow:(NSNotification *)notification {
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    [self.nameTextField resignFirstResponder];
    
    if (self.amountTextField) {
        
        [self.amountTextField resignFirstResponder];
    }
}

#pragma mark - Text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 2) { // Amount text field
        
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
        self.amountValue = amount;
        textField.text = [self.numberFormatter stringFromNumber:amount];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.tag == 2) { // Amount text field
        
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
    }
    
    return YES;
}

#pragma mark - Load model data
- (void)loadServiceProviderDetails {
    
    // Get service provider details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Service Providers" ofType:@"plist"];
    NSDictionary *serviceProvidersDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.serviceProviderDetails = serviceProvidersDict[@"ServiceProviders"];
}

- (void)loadServiceProviderListItems {
    
    if (self.serviceProviderListItems == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ServiceProvider" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *serviceProviderEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *serviceProviders = [@[] mutableCopy];
        
        for (ServiceProvider *serviceProviderEntity in serviceProviderEntities) {
            
            [serviceProviders addObject:@{@"displayName" : serviceProviderEntity.providerName,
                                          @"uniqueId" : serviceProviderEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.serviceProviderListItems = [serviceProviders sortedArrayUsingDescriptors:@[descriptor]];
    }
}

- (void)loadPaymentTypeDetails {
    
    // Get payment type details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Payment Types" ofType:@"plist"];
    NSDictionary *paymentTypesDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.paymentTypeDetails = paymentTypesDict[@"PaymentTypes"];
}

- (void)loadPaymentTypeListItems {
    
    if (self.paymentTypeListItems == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaymentType" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *paymentTypeEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *paymentTypes = [@[] mutableCopy];
        
        for (PaymentType *paymentTypeEntity in paymentTypeEntities) {
            
            [paymentTypes addObject:@{@"displayName" : paymentTypeEntity.typeName,
                                          @"uniqueId" : paymentTypeEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.paymentTypeListItems = [paymentTypes sortedArrayUsingDescriptors:@[descriptor]];
        self.filteredPaymentTypeListItems = [self.paymentTypeListItems copy];
    }
}

- (void)loadPaymentMethodDetails {
    
    // Get payment method details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Payment Methods" ofType:@"plist"];
    NSDictionary *paymentMethodsDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.paymentMethodDetails = paymentMethodsDict[@"PaymentMethods"];
}

- (void)loadPaymentMethodListItems {
    
    if (self.paymentMethodListItems == nil) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaymentMethod" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *paymentMethodEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *paymentMethods = [@[] mutableCopy];
        
        for (PaymentMethod *paymentMethodEntity in paymentMethodEntities) {
            
            [paymentMethods addObject:@{@"displayName" : paymentMethodEntity.methodName,
                                      @"uniqueId" : paymentMethodEntity.uniqueId}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.paymentMethodListItems = [paymentMethods sortedArrayUsingDescriptors:@[descriptor]];
        self.filteredPaymentMethodListItems = [self.paymentMethodListItems copy];
    }
}

#pragma mark - Selection filters
- (void)filterRelatedPaymentTypesBySelectedServiceProvider {
    
    if (self.selectedServiceProvider != nil) {
    
        NSArray *relatedPaymentTypes;
        
        // Get related payment types for service provider
        for (NSDictionary *serviceProviderDetails in self.serviceProviderDetails) {
            
            if ([serviceProviderDetails[@"Service Provider"] isEqualToString:self.selectedServiceProvider[@"displayName"]]) {
                
                relatedPaymentTypes = serviceProviderDetails[@"Related Payment Types"];
                break;
            }
        }
        
        // Remove payment type list items not applicable for selected provider
        NSMutableArray *filteredPaymentTypes = [self.paymentTypeListItems mutableCopy];
        
        for (NSDictionary *paymentTypeDictionary in self.paymentTypeListItems) {
            
            if (![relatedPaymentTypes containsObject:paymentTypeDictionary[@"displayName"]]) {
                
                [filteredPaymentTypes removeObject:paymentTypeDictionary];
            }
        }
        
        self.filteredPaymentTypeListItems = [filteredPaymentTypes copy];
        
    } else {
        
        NSLog(@"Selected service provider not set");
    }
}

- (void)filterRelatedPaymentMethodsBySelectedPaymentType {
    
    if (self.selectedPaymentType != nil) {
    
        NSArray *relatedPaymentMethods;
        
        // Get related payment methods for payment type
        for (NSDictionary *paymentTypeDetails in self.paymentTypeDetails) {
            
            if ([paymentTypeDetails[@"Payment Type"] isEqualToString:self.selectedPaymentType[@"displayName"]]) {
                
                relatedPaymentMethods = paymentTypeDetails[@"Related Payment Methods"];
                break;
            }
        }
        
        // Remove payment methods list items not applicable for selected payment type
        NSMutableArray *filteredPaymentMethods = [self.paymentMethodListItems mutableCopy];
        
        for (NSDictionary *paymentMethodDictionary in self.paymentMethodListItems) {
            
            if (![relatedPaymentMethods containsObject:paymentMethodDictionary[@"displayName"]]) {
                
                [filteredPaymentMethods removeObject:paymentMethodDictionary];
            }
        }
        
        self.filteredPaymentMethodListItems = [filteredPaymentMethods copy];
        
    } else {
        
        NSLog(@"Selected payment type not set");
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.tableRowData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSDictionary *rowData = self.tableRowData[indexPath.row];
    
    if (indexPath.row == kChargeTypeNameRow) {
        
        ChargeTypeNameCell *nameCell = [tableView dequeueReusableCellWithIdentifier:kChargeTypeNameCellIdentifier forIndexPath:indexPath];
        
        nameCell.nameLabel.text = rowData[@"rowTitleString"];
        nameCell.nameTextField.text = rowData[@"rowDetailString"];
        self.nameTextField = nameCell.nameTextField;
        
        cell = nameCell;
        
    } else if (indexPath.row > kChargeTypeNameRow &&
               indexPath.row < kPaymentAmountRow) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kChargeTypeCellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = rowData[@"rowTitleString"];
        cell.detailTextLabel.text = rowData[@"rowDetailString"];
        
        // Disable payment type row selection if no service provider selected
        if (indexPath.row == kPaymentTypeRow) {
            
            NSDictionary *serviceProviderRowData = self.tableRowData[kServiceProviderRow];
            
            if ([serviceProviderRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.userInteractionEnabled = NO;
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                
            } else {
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.userInteractionEnabled = YES;
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
        }
        
        // Disable payment method row selection if no payment type selected
        if (indexPath.row == kPaymentMethodRow) {
            
            NSDictionary *paymentTypeRowData = self.tableRowData[kPaymentTypeRow];
            
            if ([paymentTypeRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.userInteractionEnabled = NO;
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                
            } else {
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.userInteractionEnabled = YES;
                cell.detailTextLabel.textColor = [UIColor blackColor];
            }
        }
        
    } else {
    
        // Enable payment amount row only when payment method has been selected
        ChargeTypeAmountCell *amountCell = [tableView dequeueReusableCellWithIdentifier:kChargeTypeAmountCellIdentifier forIndexPath:indexPath];
        
        //amountCell.amountTitleLabel.text = rowData[@"rowTitleString"];
        amountCell.amountTitleLabel.text = self.localeCurrencySymbol;
        amountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *paymentMethodRowData = self.tableRowData[kPaymentMethodRow];
        
        if ([paymentMethodRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
            
            amountCell.userInteractionEnabled = NO;
            amountCell.amountTextField.hidden = YES;
            amountCell.amountDetailLabel.hidden = NO;
            amountCell.amountDetailLabel.textColor = [UIColor lightGrayColor];
            amountCell.amountDetailLabel.text = @"None";

        } else {
            
            // Display amount text field or label
            amountCell.userInteractionEnabled = YES;
            
            if ([paymentMethodRowData[@"rowDetailString"] isEqualToString:kPayPerAppointment]) {
                
                amountCell.amountTextField.hidden = YES;
                amountCell.amountDetailLabel.hidden = NO;
                amountCell.amountDetailLabel.textColor = [UIColor blackColor];
                amountCell.amountDetailLabel.text = NSLocalizedString(@"Enter an amount when completing an appointment", @"Appointment amount");
                
            } else if ([paymentMethodRowData[@"rowDetailString"] isEqualToString:kPayPerCourseOfTreatment]) {
                
                amountCell.amountTextField.hidden = YES;
                amountCell.amountDetailLabel.hidden = NO;
                amountCell.amountDetailLabel.textColor = [UIColor blackColor];
                amountCell.amountDetailLabel.text = NSLocalizedString(@"Enter an amount when completing a course of treatment", @"Appointment course amount");
                
            } else {
                
                amountCell.amountDetailLabel.hidden = YES;
                amountCell.amountTextField.hidden = NO;
                
                if ([paymentMethodRowData[@"rowDetailString"] isEqualToString:kExempt]) {
                    
                    amountCell.amountTextField.text = @"";
                    amountCell.userInteractionEnabled = NO;
                    amountCell.amountTextField.textColor = [UIColor lightGrayColor];
                    
                } else {
                    
                    // Format amount value
                    self.numberFormatter.minimumFractionDigits = 2;
                    amountCell.amountTextField.text = [self.numberFormatter stringFromNumber:self.amountValue];
                    
                    amountCell.userInteractionEnabled = YES;
                    amountCell.amountTextField.textColor = [UIColor blackColor];

                }
                
                self.amountTextField = amountCell.amountTextField;
            }
        }
        
        cell = amountCell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case kServiceProviderRow: {
            [self performSegueWithIdentifier:@"ShowSelectServiceProviderView" sender:nil];
            break;
        }
        case kPaymentTypeRow: {
            [self performSegueWithIdentifier:@"ShowSelectPaymentTypeView" sender:nil];
            break;
        }
        case kPaymentMethodRow: {
            [self performSegueWithIdentifier:@"ShowSelectPaymentMethodView" sender:nil];
            break;
        }
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowSelectServiceProviderView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Service Provider", @"Service Provider");
        
        selectionListViewController.selectionList = self.serviceProviderListItems;
        
        // Pre-select service provider if already selected
        if (self.selectedServiceProvider != nil) {
            
            NSInteger selectedServiceProviderIndex = [self.serviceProviderListItems indexOfObject:self.selectedServiceProvider];
            selectionListViewController.initialSelection = selectedServiceProviderIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.autoReturnAfterSelection = YES;
        
        // Set section header text
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a service provider for this charge type", @"Please select a service provider for this charge type");
        
        // Set section footer text
        selectionListViewController.sectionFooter = NSLocalizedString(@"Normally, your dental care service will be provided in one of three ways:\n\n• Private – all of your dental treatment is provided privately.\n\n• State – all of your dental treatment is provided by the state.\n\n• State and Private – part of your dental treatment is provided by the state and part is provided privately.", @"Service provider description");
        
    } else if ([[segue identifier] isEqualToString:@"ShowSelectPaymentTypeView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Payment Type", @"Payment Type");
        
        selectionListViewController.selectionList = self.filteredPaymentTypeListItems;
        
        // Pre-select payment type if already selected
        if (self.selectedPaymentType != nil) {
            
            NSInteger selectedPaymentTypeIndex = [self.filteredPaymentTypeListItems indexOfObject:self.selectedPaymentType];
            selectionListViewController.initialSelection = selectedPaymentTypeIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.autoReturnAfterSelection = YES;
        
        // Set section header text
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a payment type for this charge type", @"Please select a payment type for this charge type");
        
        // Set section footer text
        selectionListViewController.sectionFooter = NSLocalizedString(@"There are different payment types depending on how you receive your dental treatment. Common forms of payment types are listed below:\n\n• Exempt – the state pays for all of your dental treatment but restrictions apply.\n\n• Part-Exempt – the state pays for some of your dental treatment but further restrictions apply.\n\n• State – you pay for all of your dental treatment provided by the state.\n\n• State and Private – you pay for all of your dental treatment, part of which is provided by the state and part of which is provided privately.\n\n• Private – you pay for all of your dental treatment which is provided privately.\n\n• Personal Health, Medical or Dental Insurance – you have a personal policy which covers the cost of part or all of your dental treatment.\n\n• Employer Health, Medical or Dental Insurance – you have a policy where your employer covers the cost of part or all of your dental treatment.", @"Payment type description");
        
    } else if ([[segue identifier] isEqualToString:@"ShowSelectPaymentMethodView"]) {
        
        SingleSelectionListViewController *selectionListViewController = [segue destinationViewController];
        selectionListViewController.navigationItem.title = NSLocalizedString(@"Payment Method", @"Payment Method");
        
        selectionListViewController.selectionList = self.filteredPaymentMethodListItems;
        
        // Pre-select payment method if already selected
        if (self.selectedPaymentMethod != nil) {
            
            NSInteger selectedPaymentMethodIndex = [self.filteredPaymentMethodListItems indexOfObject:self.selectedPaymentMethod];
            selectionListViewController.initialSelection = selectedPaymentMethodIndex;
        }
        
        selectionListViewController.delegate = self;
        selectionListViewController.autoReturnAfterSelection = YES;
        
        // Set section header text
        selectionListViewController.sectionHeader = NSLocalizedString(@"Please select a payment method for this charge type", @"Please select a payment method for this charge type");
        
        // Set section footer text
        selectionListViewController.sectionFooter = NSLocalizedString(@"You will normally be offered a variety of methods by which you can pay for your dental treatment. Common payment methods are listed below:\n\n• Weekly Payment – you make a regular weekly payment to cover your dental treatment (e.g., capitation scheme, cash plan, treatment loan, credit agreement).\n\n• Monthly Payment – you make a regular monthly payment to cover your dental treatment (e.g., capitation scheme, cash plan, treatment loan, credit agreement).\n\n• Quarterly Payment – You make a regular quarterly payment to cover your dental treatment (e.g., capitation scheme, cash plan, treatment loan, credit agreement).\n\n• Annual Payment – you make a regular annual payment to cover your dental treatment (e.g., capitation scheme, cash plan, treatment loan, credit agreement).\n\n• Pay per Appointment – You pay for the treatment you receive at the end of each appointment.\n\n• Pay per Course of Treatment – you pay for the treatment you receive at the end of a course of treatment.", @"Payment method description");
    }
}

- (void)singleSelectionListViewControllerDidFinish:(SingleSelectionListViewController *)controller withSelectedItem:(NSDictionary *)selectedItem {
    
    if ([controller.navigationItem.title isEqualToString:@"Service Provider"]) {
        
        self.selectedServiceProvider = selectedItem;
        
        // Update table row data
        NSMutableDictionary *tableRowDict = self.tableRowData[kServiceProviderRow];
        tableRowDict[@"rowDetailString"] = selectedItem[@"displayName"];
    
        // Reset payment type and payment method selections if we've selected a new service provider
        if (self.selectedPaymentType) {
            
            self.selectedPaymentType = nil;
            NSMutableDictionary *tableRowDict = self.tableRowData[kPaymentTypeRow];
            tableRowDict[@"rowDetailString"] = kPleaseSelect;
            
            if (self.selectedPaymentMethod) {
                
                self.selectedPaymentMethod = nil;
                NSMutableDictionary *tableRowDict = self.tableRowData[kPaymentMethodRow];
                tableRowDict[@"rowDetailString"] = kPleaseSelect;
            }
        }
        
        // Filter payment types by selected service provider
        [self filterRelatedPaymentTypesBySelectedServiceProvider];
        
    } else if ([controller.navigationItem.title isEqualToString:@"Payment Type"]) {
        
        self.selectedPaymentType = selectedItem;
        
        // Update table row data
        NSMutableDictionary *tableRowDict = self.tableRowData[kPaymentTypeRow];
        tableRowDict[@"rowDetailString"] = selectedItem[@"displayName"];
        
        // Reset payment method selection if we've selected a new payment type
        if (self.selectedPaymentMethod) {
            
            self.selectedPaymentMethod = nil;
            self.filteredPaymentMethodListItems = [self.paymentMethodListItems copy];
            NSMutableDictionary *tableRowDict = self.tableRowData[kPaymentMethodRow];
            tableRowDict[@"rowDetailString"] = kPleaseSelect;
        }
        
        // Filter payment methods by selected payment type
        [self filterRelatedPaymentMethodsBySelectedPaymentType];
        
    } else if ([controller.navigationItem.title isEqualToString:@"Payment Method"]) {
    
        self.selectedPaymentMethod = selectedItem;
        
        // Update table row data
        NSMutableDictionary *tableRowDict = self.tableRowData[kPaymentMethodRow];
        tableRowDict[@"rowDetailString"] = selectedItem[@"displayName"];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Button actions
- (IBAction)cancelTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(chargeTypeDetailViewControllerDidCancel)]) {
        
        [self.delegate chargeTypeDetailViewControllerDidCancel];
    }
}

- (IBAction)doneTapped:(id)sender {
    
    // Validate fields
    BOOL isValidated = YES;
    
    if ([self.nameTextField.text isEqualToString:@""]) {
        
        [self wobbleView:self.nameTextField];
        isValidated = NO;
    }
    
    NSDictionary *serviceProviderRowData = self.tableRowData[kServiceProviderRow];
    if ([serviceProviderRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
        
        UITableViewCell *serviceProviderCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kServiceProviderRow inSection:0]];
        
        [self wobbleView:serviceProviderCell.detailTextLabel];
        isValidated = NO;
    }

    NSDictionary *paymentTypeRowData = self.tableRowData[kPaymentTypeRow];
    if ([paymentTypeRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
        
        UITableViewCell *paymentTypeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPaymentTypeRow inSection:0]];
        
        if (paymentTypeCell.userInteractionEnabled) {
            
            [self wobbleView:paymentTypeCell.detailTextLabel];
        }
        
        isValidated = NO;
    }

    NSDictionary *paymentMethodRowData = self.tableRowData[kPaymentMethodRow];
    if ([paymentMethodRowData[@"rowDetailString"] isEqualToString:kPleaseSelect]) {
        
        UITableViewCell *paymentMethodCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPaymentMethodRow inSection:0]];
        
        if (paymentMethodCell.userInteractionEnabled) {
            
            [self wobbleView:paymentMethodCell.detailTextLabel];
        }
        
        isValidated = NO;
    }
    
    if (!self.amountTextField.isHidden) {
        
        if ([self.amountTextField.text isEqualToString:@""]) {
            
            [self wobbleView:self.amountTextField];
            isValidated = NO;
        }
    }
    
    if (isValidated) {
        
        // Save charge type
        ChargeType *chargeType;
        
        if (self.editingChargeType) {
            
            chargeType = self.editingChargeType;
            
        } else {
            
            chargeType = (ChargeType *)[NSEntityDescription insertNewObjectForEntityForName:@"ChargeType" inManagedObjectContext:self.managedObjectContext];
            
            // Unique id
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [chargeType setUniqueId:uuid];
            
        }
        
        chargeType.typeName = self.nameTextField.text;
        
        chargeType.serviceProvider = [ServiceProvider serviceProviderWithUniqueId:self.selectedServiceProvider[@"uniqueId"]];;
        
        chargeType.paymentType = [PaymentType paymentTypeWithUniqueId:self.selectedPaymentType[@"uniqueId"]];
        
        chargeType.paymentMethod = [PaymentMethod paymentMethodWithUniqueId:self.selectedPaymentMethod[@"uniqueId"]];
        
        if (self.amountTextField != nil && !self.amountTextField.isHidden) {
            
            chargeType.regularAmount = self.amountValue;
            
        } else {
            
            chargeType.regularAmount = (NSDecimalNumber *)[NSDecimalNumber numberWithInt:-1];
        }
        
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self.delegate chargeTypeDetailViewControllerDidFinishWithChargeType:chargeType];
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