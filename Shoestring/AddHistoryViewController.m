//
//  AddHistoryViewController.m
//  Shoestring
//
//  Created by mark on 16/10/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddHistoryViewController.h"

@interface AddHistoryViewController ()

@end

@implementation AddHistoryViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;

@synthesize currentExpense;

@synthesize datePicker;
@synthesize dateLabel;
@synthesize chosenDate;
@synthesize saveBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [datePicker setDatePickerMode:UIDatePickerModeDate];

        NSError *error = nil;
        if(![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Error! %@", error);
            abort();
        }
    [[self saveBtn]setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)save:(id)sender {
    
    //save the date with an Expense (basic)
    
    [[self currentExpense]setCategory:@"Food"];
    [[self currentExpense]setItemName:@"drink"];
    [[self currentExpense]setAmount:[NSNumber numberWithInt:2]];
    [[self currentExpense]setDate:[self chosenDate]];
    
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    if(![context save:&error]) {
        NSLog(@"Error! %@", error);
    }
    
    [self.delegate addHistoryViewControllerDidSave];
}



- (IBAction)cancel:(id)sender {
    // dismiss and remove the object
    [self.delegate addHistoryViewControllerDidCancel:[self currentExpense]];
    NSLog(@"cancelling");
}

/*
 Method is called when pickerView changed
 */

- (IBAction)displayDate:(id)sender {
    
    NSDate *chosen = [datePicker date];
    
    [self setChosenDate:[self formatDate:chosen]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEEE MMM d YYYY"];
    NSString *dateChosen = [formatter stringFromDate:chosen];
    
    NSLog(@"chosen date: %@", [self chosenDate]);
    
    //get the expense data
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    
    //check all the saved dates against the current dates
    int dateAlready = 0;
    for (Expense *current in fetchedData ) {
        if([[self chosenDate]isEqualToDate:[current date]]) {
            dateAlready++;
        }
    }
    // Check 1: if there is a dated expense already there
    if(dateAlready > 0) {
        [[self dateLabel]setText:@"Sorry that date is already there"];
        [[self saveBtn]setEnabled:NO];
    } else {
        //Check 2: if date is earlier than today
        if([self date1:[self chosenDate] isLaterThanOrEqualTo:[self formatDate:[NSDate date]]]) {
            
            [[self dateLabel]setText:@"Sorry choose and earlier date"];
            [[self saveBtn]setEnabled:NO];
            
        } else {
            
            //wecan save now
            [dateLabel setText:dateChosen];
            [[self saveBtn]setEnabled:YES];

        }
    }
}


#pragma mark -
#pragma mark Fetched Results Controller
    
    -(NSFetchedResultsController*) fetchedResultsController {
        
        if(_fetchedResultsController != nil) {
            return _fetchedResultsController;
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                       ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self managedObjectContext] sectionNameKeyPath: @"date"
                                                                                   cacheName:nil];
        
        //set this class as the delegate for the fetchedResults controller
        [_fetchedResultsController setDelegate:self];
        
        return _fetchedResultsController;
    }


-(NSDate*) formatDate: (NSDate*) date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    //set date components so that we have just the day date
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return[calendar dateFromComponents:components];
}

-(BOOL)date1:(NSDate*)date1 isLaterThanOrEqualTo:(NSDate*)date2 {
    return !([date1 compare:date2] == NSOrderedAscending);
}

@end
