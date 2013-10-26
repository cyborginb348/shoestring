//
//  DayViewController.h
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
#import "SelectDateViewController.h"

#import "Expense.h"

@interface DayViewController : UIViewController
<AddExpenseViewControllerDelegate, NSFetchedResultsControllerDelegate, SelectDateViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSDate *currentDate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *total;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeDateButton;

- (NSNumber*)calculateTotal: (NSDate*) date forManagedObjectContext: (NSManagedObjectContext*) managedObjectContext;

@end
