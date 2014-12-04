//
//  ChargeTypeViewController_iPad.m
//  myTeeth
//
//  Created by David Canty on 24/08/2014.
//  Copyright (c) 2014 David Canty. All rights reserved.
//

#import "ChargeTypeViewController_iPad.h"
#import "SingleSelectionPopoverContentViewController.h"
#import "ChargeType+Utils.h"
#import "PaymentType+Utils.h"
#import "PaymentMethod+Utils.h"
#import "Constants.h"

//typedef NS_ENUM(NSInteger, TreatmentChargeType) {
//    TreatmentChargeTypeState,
//    TreatmentChargeTypePrivate,
//    TreatmentChargeTypeStatePrivate
//};
//
//typedef NS_ENUM(NSInteger, TreatmentPaymentType) {
//    TreatmentPaymentTypeExempt,
//    TreatmentPaymentTypePartExempt,
//    TreatmentPaymentTypeState,
//    TreatmentPaymentTypeStatePrivate,
//    TreatmentPaymentTypePrivate,
//    TreatmentPaymentTypePersonalHealth,
//    TreatmentPaymentTypeEmployerHealth
//};
//
//typedef NS_ENUM(NSInteger, TreatmentPaymentMethod) {
//    TreatmentPaymentMethodWeekly,
//    TreatmentPaymentMethodMonthly,
//    TreatmentPaymentMethodQuarterly,
//    TreatmentPaymentMethodAnnual,
//    TreatmentPaymentMethodAppointment,
//    TreatmentPaymentMethodCourse
//};

// Charge Type Constants
static NSString * const kChargeTypeState            = @"State";
static NSString * const kChargeTypePrivate          = @"Private";
static NSString * const kChargeTypeStatePrivate     = @"State and Private";

// Payment Type Constants
static NSString * const kPaymentTypeExempt          = @"Exempt";
static NSString * const kPaymentTypePartExempt      = @"Part-Exempt";
static NSString * const kPaymentTypeState           = @"State";
static NSString * const kPaymentTypeStatePrivate    = @"State and Private";
static NSString * const kPaymentTypePrivate         = @"Private";
static NSString * const kPaymentTypePersonal        = @"Personal Health, Medical or Dental Insurance";
static NSString * const kPaymentTypeEmployer        = @"Employer Health, Medical or Dental Insurance";

// Payment Method Constants
static NSString * const kPaymentMethodWeekly        = @"Weekly Payment";
static NSString * const kPaymentMethodMonthly       = @"Monthly Payment";
static NSString * const kPaymentMethodQuarterly     = @"Quarterly Payment";
static NSString * const kPaymentMethodAnnual        = @"Annual Payment";
static NSString * const kPaymentMethodAppointment   = @"Pay per Appointment";
static NSString * const kPaymentMethodCourse        = @"Pay per Course of Treatment";

@interface ChargeTypeViewController_iPad () <SingleSelectionPopoverContentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *chargeTypeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *chargeTypeActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *chargeTypeTextView;
@property (weak, nonatomic) IBOutlet UIButton *chargeTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *paymentTypeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *paymentTypeActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *paymentTypeTextView;
@property (weak, nonatomic) IBOutlet UIButton *paymentTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *paymentMethodActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *paymentMethodTextView;
@property (weak, nonatomic) IBOutlet UIButton *paymentMethodButton;

@property (strong, nonatomic) SingleSelectionPopoverContentViewController *singleSelectionPopoverVC;

@property (strong, nonatomic) UIPopoverController *chargeTypePopoverController;
@property (strong, nonatomic) UIPopoverController *paymentTypePopoverController;
@property (strong, nonatomic) UIPopoverController *paymentMethodPopoverController;
@property (strong, nonatomic) UIPopoverController *paymentCurrencyPopoverController;

@property (strong, nonatomic) NSArray *chargeTypeDetails;
@property (strong, nonatomic) NSArray *paymentTypeDetails;

@property (strong, nonatomic) NSArray *paymentTypeEntities;
@property (strong, nonatomic) NSArray *paymentMethodEntities;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation ChargeTypeViewController_iPad


#pragma mark - View lifecycle
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadChargeTypeDetails];
    [self loadPaymentTypeDetails];
    [self loadPaymentTypeEntities];
    [self loadPaymentMethodEntities];
    
    if (self.isEditing) {
        
        // Pre-populate fields and filter selection list items
        self.chargeTypeLabel.text = self.selectedChargeType.chargeType;
        [self filterPaymentTypesOnSelectedChargeType];
        self.paymentTypeLabel.text = self.selectedPaymentType.paymentType;
        [self filterPaymentMethodsOnSelectedPaymentType];
        self.paymentMethodLabel.text = self.selectedPaymentMethod.paymentMethod;
        
    } else {
        
        // Disable payment type and payment method buttons
        self.paymentTypeButton.enabled = NO;
        self.paymentTypeLabel.enabled = NO;
        self.paymentMethodButton.enabled = NO;
        self.paymentMethodLabel.enabled = NO;
    }
}

- (void)loadChargeTypeDetails {
    
    // Get charge type details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Charge Types" ofType:@"plist"];
    NSDictionary *chargeTypesDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.chargeTypeDetails = chargeTypesDict[@"ChargeTypes"];
}

- (void)loadPaymentTypeDetails {
    
    // Get payment type details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Payment Types" ofType:@"plist"];
    NSDictionary *paymentTypesDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.paymentTypeDetails = paymentTypesDict[@"PaymentTypes"];
}

- (void)loadPaymentTypeEntities {
    
    // Get payment type entities from core data
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PaymentType" inManagedObjectContext:self.managedObjectContext]];
    NSError *error;
    self.paymentTypeEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)loadPaymentMethodEntities {
    
    // Get payment method entities from core data
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PaymentMethod" inManagedObjectContext:self.managedObjectContext]];
    NSError *error;
    self.paymentMethodEntities = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (NSArray *)getRelatedPaymentTypesForSelectedChargeType {
    
    NSArray *relatedPaymentTypes;
    if (self.selectedChargeType != nil) {
        
        for (NSDictionary *chargeTypeDetails in self.chargeTypeDetails) {
            
            if ([chargeTypeDetails[@"Charge Type"] isEqualToString:self.selectedChargeType.chargeType]) {
                
                relatedPaymentTypes = chargeTypeDetails[@"Related Payment Types"];
                break;
            }
        }
        
    } else {
        
        NSLog(@"Selected charge type not set");
    }
    
    return relatedPaymentTypes;
}

- (NSArray *)getRelatedPaymentMethodsForSelectedPaymentType {
    
    NSArray *relatedPaymentMethods;
    if (self.selectedPaymentType != nil) {
        
        for (NSDictionary *paymentTypeDetails in self.paymentTypeDetails) {
            
            if ([paymentTypeDetails[@"Payment Type"] isEqualToString:self.selectedPaymentType.paymentType]) {
                
                relatedPaymentMethods = paymentTypeDetails[@"Related Payment Methods"];
                break;
            }
        }
        
    } else {
        
        NSLog(@"Selected payment type not set");
    }
    
    return relatedPaymentMethods;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Seque navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"ShowChargeTypePopover"]) {
        
        // Select charge type from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"ChargeType";
        self.singleSelectionPopoverVC.sortDescriptor = @"chargeType";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.predicate = nil;
        self.singleSelectionPopoverVC.attributeForDisplay = @"chargeType";
        
        if (self.selectedChargeType != nil) {
            
            self.singleSelectionPopoverVC.selectedObjectId = self.selectedChargeType.objectID;
        }
        
        self.singleSelectionPopoverVC.delegate = self;
        
        // Store reference to popover for dismissal after item selected
        self.chargeTypePopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
    
    if ([segue.identifier isEqualToString: @"ShowPaymentTypePopover"]) {
     
        // Select payment type from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"PaymentType";
        self.singleSelectionPopoverVC.sortDescriptor = @"paymentType";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.attributeForDisplay = @"paymentType";
        NSPredicate *filteredPredicate = [NSPredicate predicateWithFormat:@"filtered = %@",[NSNumber numberWithBool: YES]];
        self.singleSelectionPopoverVC.predicate = filteredPredicate;
        
        if (self.selectedPaymentType != nil) {
            
            self.singleSelectionPopoverVC.selectedObjectId = self.selectedPaymentType.objectID;
        }
        
        self.singleSelectionPopoverVC.delegate = self;
        
        // Store reference to popover for dismissal after item selected
        self.paymentTypePopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
    
    if ([segue.identifier isEqualToString: @"ShowPaymentMethodPopover"]) {

        // Select payment method from popover
        self.singleSelectionPopoverVC = (SingleSelectionPopoverContentViewController *)[segue destinationViewController];
        
        self.singleSelectionPopoverVC.managedObjectContext = self.managedObjectContext;
        self.singleSelectionPopoverVC.entityName = @"PaymentMethod";
        self.singleSelectionPopoverVC.sortDescriptor = @"paymentMethod";
        self.singleSelectionPopoverVC.isSortDescriptorAscending = YES;
        self.singleSelectionPopoverVC.attributeForDisplay = @"paymentMethod";
        NSPredicate *filteredPredicate = [NSPredicate predicateWithFormat:@"filtered = %@",[NSNumber numberWithBool: YES]];
        self.singleSelectionPopoverVC.predicate = filteredPredicate;
        
        if (self.selectedPaymentMethod != nil) {
            
            self.singleSelectionPopoverVC.selectedObjectId = self.selectedPaymentMethod.objectID;
        }
        
        self.singleSelectionPopoverVC.delegate = self;
        
        // Store reference to popover for dismissal after item selected
        self.paymentMethodPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

#pragma mark - Single selection popover delegate
- (void)singleSelectionPopoverContentViewControllerDidFinishWithObject:(NSManagedObject *)selectedObject {
    
    // Store selected object and dismiss popover
    if ([selectedObject isKindOfClass:[ChargeType class]]) {
        
        self.selectedChargeType = (ChargeType *)selectedObject;
        [self.chargeTypePopoverController dismissPopoverAnimated:YES];
        self.chargeTypeLabel.text = self.selectedChargeType.chargeType;
        
        [self filterPaymentTypesOnSelectedChargeType];
        
        // Reset payment type and payment method selections if we've selected a new charge type
        if (self.selectedPaymentType) {
            
            self.selectedPaymentType = nil;
            self.paymentTypeLabel.text = kPleaseSelect;
            self.paymentTypeButton.enabled = YES;
            self.paymentTypeLabel.enabled = YES;
            
            if (self.selectedPaymentMethod) {
                
                self.selectedPaymentMethod = nil;
                self.paymentMethodLabel.text = kPleaseSelect;
                self.paymentMethodButton.enabled = NO;
                self.paymentMethodLabel.enabled = NO;
            }
        }
        
    } else if ([selectedObject isKindOfClass:[PaymentType class]]) {
        
        self.selectedPaymentType = (PaymentType *)selectedObject;
        [self.paymentTypePopoverController dismissPopoverAnimated:YES];
        self.paymentTypeLabel.text = self.selectedPaymentType.paymentType;
        
        [self filterPaymentMethodsOnSelectedPaymentType];
        
        // Reset payment method selection if we've selected a new payment type
        if (self.selectedPaymentMethod) {
            
            self.selectedPaymentMethod = nil;
            self.paymentMethodLabel.text = kPleaseSelect;
            self.paymentMethodButton.enabled = YES;
            self.paymentMethodLabel.enabled = YES;
        }
        
    } else if ([selectedObject isKindOfClass:[PaymentMethod class]]) {
        
        self.selectedPaymentMethod = (PaymentMethod *)selectedObject;
        [self.paymentMethodPopoverController dismissPopoverAnimated:YES];
        self.paymentMethodLabel.text = self.selectedPaymentMethod.paymentMethod;
    }
}

- (void)filterPaymentTypesOnSelectedChargeType {
    
    // Filter payment types on selected charge type
    [self.paymentTypeActivityIndicator startAnimating];
    if (self.paymentTypeEntities != nil) {
        
        NSArray *relatedPaymentTypes = [self getRelatedPaymentTypesForSelectedChargeType];
        
        for (PaymentType *paymentTypeEntity in self.paymentTypeEntities) {
            
            if ([relatedPaymentTypes containsObject:paymentTypeEntity.paymentType]) {
                
                paymentTypeEntity.filtered = [NSNumber numberWithBool:YES];
                
            } else {
                
                paymentTypeEntity.filtered = [NSNumber numberWithBool:NO];
            }
        }
        
        // Save the context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            
            NSLog(@"Error saving filtered payment types. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.paymentTypeActivityIndicator stopAnimating];
        self.paymentTypeButton.enabled = YES;
        self.paymentTypeLabel.enabled = YES;
    }
}

- (void)filterPaymentMethodsOnSelectedPaymentType {
    
    // Filter payment methods on selected payment type
    [self.paymentMethodActivityIndicator startAnimating];
    if (self.paymentMethodEntities != nil) {
        
        NSArray *relatedPaymentMethods = [self getRelatedPaymentMethodsForSelectedPaymentType];
        
        for (PaymentMethod *paymentMethodEntity in self.paymentMethodEntities) {
            
            if ([relatedPaymentMethods containsObject:paymentMethodEntity.paymentMethod]) {
                
                paymentMethodEntity.filtered = [NSNumber numberWithBool:YES];
                
            } else {
                
                paymentMethodEntity.filtered = [NSNumber numberWithBool:NO];
            }
        }
        
        // Save the context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            
            NSLog(@"Error saving filtered payment methods. Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.paymentMethodActivityIndicator stopAnimating];
        self.paymentMethodButton.enabled = YES;
        self.paymentMethodLabel.enabled = YES;
    }
}

- (IBAction)doneButtonTapped:(id)sender {

    // Validate fields
    BOOL isValidated = YES;
    if (self.selectedChargeType == nil) {
        
        [self wobbleButton:self.chargeTypeButton];
        isValidated = NO;
    }
    if (self.selectedPaymentType == nil &&
        self.paymentTypeButton.enabled) {
        
        [self wobbleButton:self.paymentTypeButton];
        isValidated = NO;
    }
    if (self.selectedPaymentMethod == nil &&
        self.paymentMethodButton.enabled) {
        
        [self wobbleButton:self.paymentMethodButton];
        isValidated = NO;
    }
    
    // Call delegate finish method
    if (isValidated) {
        
        [[self delegate] chargeTypeViewControllerDidFinishWithChargeType:self.selectedChargeType paymentType:self.selectedPaymentType paymentMethod:self.selectedPaymentMethod];
    }
    
}

- (void)wobbleButton:(UIButton *)buttonToWobble {
    
    CAKeyframeAnimation *wobble = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    wobble.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                      [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)]];
    wobble.autoreverses = YES;
    wobble.repeatCount = 2.0f;
    wobble.duration = 0.10f;
    [buttonToWobble.layer addAnimation:wobble forKey:nil];
}

@end