//
//  AddExpenseViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expense.h"
#import "CategoryButtons.h"
#import "StarRatingControl.h"

@protocol AddExpenseViewControllerDelegate;

@interface AddExpenseViewController : UIViewController
<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CategoryButtonsDelegate, StarRatingDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

-(NSDate*) getTodaysDate;

@property (weak, nonatomic) IBOutlet UIView *categoryView;

@property (weak, nonatomic) IBOutlet StarRatingControl *starRatingControl;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) NSArray *ratingLabels;


@property (nonatomic, strong) Expense *currentExpense;
@property (nonatomic, strong) NSString *currentCategory;
@property (weak, nonatomic) IBOutlet UITextField *itemNameField;
@property (weak, nonatomic) IBOutlet UITextField *placeNameField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *savingTipField;
@property  NSUInteger rate;


@property (nonatomic, weak) id <AddExpenseViewControllerDelegate> delegate;

@property (nonatomic, retain) UITableView *autocompleteTableView;
@property (nonatomic, retain) NSMutableArray *itemNames;
@property (nonatomic, retain) NSMutableArray *autocompleteNames;

@end


//protocol for delegate
@protocol AddExpenseViewControllerDelegate

-(void) addExpenseViewControllerDidSave;
-(void) addExpenseViewControllerDidCancel: (Expense*) expenseToDelete;


@end
