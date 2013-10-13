//
//  TodayViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AddExpenseViewController.h"
#import "ViewExpenseViewController.h"
#import "HistoryViewController.h"
#import "Expense.h"

@interface DayViewController : UITableViewController
<AddExpenseViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSDate *displayDate;

@property (weak, nonatomic) IBOutlet UILabel *total;

- (NSNumber*)calculateTotal: (NSDate*) date forManagedObjectContext: (NSManagedObjectContext*) managedObjectContext;



@end
