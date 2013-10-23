//
//  SelectDateViewController.h
//  Shoestring
//
//  Created by mark on 16/10/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Expense.h"

@protocol SelectDateViewControllerDelegate;


@interface SelectDateViewController : UIViewController
//<NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id <SelectDateViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDate *chosenDate;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@protocol SelectDateViewControllerDelegate
-(void)selectDateViewControllerDidSelect:(NSDate*)selectedDate;
-(void)selectDateViewControllerDidCancel;
@end




