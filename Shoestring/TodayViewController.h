//
//  TodayViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpenseViewController.h"
#import "ViewExpenseViewController.h"
#import "Expense.h"

@interface TodayViewController : UITableViewController
<AddExpenseViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UILabel *total;


@end
