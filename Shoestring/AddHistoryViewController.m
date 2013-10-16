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
    
    [self dismissViewControllerAnimated:YES completion:nil];    
}



- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)displayDate:(id)sender {
    
    NSDate *chosen = [datePicker date];
    
    [self setChosenDate:[self formatDate:chosen]];
    
    NSLog(@"chosen date: %@", [self chosenDate]);
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEEE MMM d YYYY"];
    
    NSString *dateChosen = [formatter stringFromDate:chosen];
     
    
    
    
    //get the expense data
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    
    for (Expense *current in fetchedData ) {
        
        //if there is a dated expense already there, or date is earlier than today
        if([[self chosenDate]isEqualToDate:[current date]] ||
           [self oneDate:[self chosenDate] isLaterThanOrEqualTo:[self formatDate:[NSDate date]]]) {
        
            [[self dateLabel]setText:@"Sorry choose and earlier date"];
            [[self saveBtn]setEnabled:NO];
        
        } else {
            
            //you can save now
            
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

-(BOOL)oneDate:(NSDate*)date1 isLaterThanOrEqualTo:(NSDate*)date2 {
    return !([date1 compare:date2] == NSOrderedAscending);
}

@end
