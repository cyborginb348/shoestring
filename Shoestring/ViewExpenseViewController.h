//
//  ViewExpenseViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expense.h"
#import "CategoryButtons.h"
#import "AppDelegate.h"
#import "StarRatingControl.h"

@interface ViewExpenseViewController : UIViewController
<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CategoryButtonsDelegate, StarRatingDelegate>

@property (strong, nonatomic) Expense *currentExpense;
@property (strong, nonatomic) NSString *currentCategory;

@property (weak, nonatomic) IBOutlet CategoryButtons *categoryView;

@property (weak, nonatomic) IBOutlet StarRatingControl *starRatingControl;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong) NSArray *ratingLabels;
@property BOOL setEditable;


@property (nonatomic) bool toggleIsOn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleBtn;
- (IBAction)toggle:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *itemNameField;
@property (weak, nonatomic) IBOutlet UITextField *placeNameField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *savingTipField;
@property NSUInteger rate;

-(int) categoryNumberFromString: (NSString*) category;

@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, retain) NSMutableArray *itemNames;
@property (nonatomic, retain) NSMutableArray *autocompleteNames;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
