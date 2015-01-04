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

- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender;
- (IBAction)addTransactionTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

@end

@implementation BillViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

#pragma mark - Transaction History table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentTransactionCellIdentifier];
    
    
    
    return cell;
}

#pragma mark - Button actions
- (IBAction)fullyPaidTapped:(UISegmentedControl *)sender {
    
    
}

- (IBAction)addTransactionTapped:(id)sender {
    
    
}

- (IBAction)cancelTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(billViewControllerDidCancel)]) {
        
        [self.delegate billViewControllerDidCancel];
    }
}

- (IBAction)doneTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(billViewControllerDidFinishWithBill:)]) {
        
        [self.delegate billViewControllerDidFinishWithBill:nil];
    }
}

@end