//
//  SelectDateViewController.m
//  Shoestring
//
//  Created by mark on 16/10/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "SelectDateViewController.h"

@interface SelectDateViewController ()

@end

@implementation SelectDateViewController

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
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setDate:self.chosenDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)save:(id)sender {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[self.datePicker date]];
    
    //set date components so that we have just the day date
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    [self.delegate selectDateViewControllerDidSelect:[calendar dateFromComponents:components]];
}



- (IBAction)cancel:(id)sender {
    
    [self.delegate selectDateViewControllerDidCancel];
}

@end
