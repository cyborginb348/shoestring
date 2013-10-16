//
//  AddHistoryViewController.h
//  Shoestring
//
//  Created by mark on 16/10/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Expense.h"

//@protocol AddHistoryViewControllerDelegate;


@interface AddHistoryViewController : UIViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Expense *currentExpense;

@property (nonatomic, strong) NSDate *chosenDate;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

- (IBAction)displayDate:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

-(NSDate*) formatDate: (NSDate*) date;

-(BOOL) oneDate:(NSDate*)date1 isLaterThanOrEqualTo:(NSDate*)date2;

@end






