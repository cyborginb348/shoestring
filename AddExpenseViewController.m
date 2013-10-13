//
//  AddExpenseViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddExpenseViewController.h"
#import "DayViewController.h"




@interface AddExpenseViewController ()

@end

@implementation AddExpenseViewController

@synthesize managedObjectContext;

@synthesize categoryView;
@synthesize currentCategory;
@synthesize itemNameField,placeNameField,amountField,savingTipField, rate;
@synthesize currentExpense;

@synthesize starRatingControl = _starRatingControl;
@synthesize ratingLabel = _ratingLabel;
@synthesize ratingLabels = _ratingLabels;

@synthesize autocompleteTableView, autocompleteNames,itemNames;

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
    
    [self initialiseAutocomplete];
	
    
    //set delegates for keyboard dismissal
    [itemNameField setDelegate:self];
    [placeNameField setDelegate:self];
    [amountField setDelegate:self];
    [savingTipField setDelegate:self];
    
    // add the category buttons
    CategoryButtons *btnView = [[CategoryButtons alloc] init];
    [btnView setDelegate:self];
    CGRect bounds = [[self view] bounds];
    [btnView setCenter: CGPointMake(bounds.size.width/2, 160)];
    [categoryView addSubview:btnView];
    
    //starRatings
    _ratingLabels = [NSArray arrayWithObjects:@"Unrated", @"Hate it", @"Don't like it", @"It's OK", @"It's good", @"It's great", nil];
	
	[[self starRatingControl] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(id)sender {
    [[self delegate] addExpenseViewControllerDidCancel: [self currentExpense]];
}

- (IBAction)save:(id)sender {
    
    [[self currentExpense]setCategory:currentCategory];
    [[self currentExpense]setItemName:[itemNameField text]];
    [[self currentExpense]setPlaceName:[placeNameField text]];
    
    NSNumberFormatter *formatString = [[NSNumberFormatter alloc]init];
    [[self currentExpense]setAmount: [formatString numberFromString:[amountField text]]];
    
    [[self currentExpense]setSavingTip:[savingTipField text]];
    [[self currentExpense]setRating: [NSNumber numberWithInt: rate]];
    [[self currentExpense]setDate:[self getTodaysDate]];
    
    [[self delegate] addExpenseViewControllerDidSave];
}

#pragma mark - CategoryButton Actions

-(void) buttonView: (CategoryButtons*) buttonView changedCategory: (NSString*)newCategory {
    currentCategory = newCategory;
}


#pragma mark - date method
-(NSDate*) getTodaysDate {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    
    //set date components so that we have just the day date
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return[calendar dateFromComponents:components];
}


#pragma mark - Dismiss keyboard

- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:YES];
    [autocompleteTableView setHidden:YES];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [autocompleteTableView setHidden:YES];
    return YES;
}


#pragma mark AutoComplete and UITextFieldDelegate methods

-(void)initialiseAutocomplete {
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, 120) style:UITableViewStylePlain];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    [autocompleteTableView setHidden:YES];
    [self.view addSubview:autocompleteTableView];
    
    self.itemNames = [[NSMutableArray alloc] initWithObjects:@"lunch",@"train",@"bus", @"dorm", @"room",@"burger",@"breakfast", @"dinner",@"beers", @"drinks", nil];
    self.autocompleteNames = [[NSMutableArray alloc] init];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    autocompleteTableView.hidden = NO;
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [autocompleteNames removeAllObjects];
    for(NSString *curString in itemNames) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [autocompleteNames addObject:curString];
        }
    }
    [autocompleteTableView reloadData];
    
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
    }
    
    cell.textLabel.text = [autocompleteNames objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    itemNameField.text = selectedCell.textLabel.text;
    autocompleteTableView.hidden = YES; 
}

-(IBAction) slideFrameUp;
{
    [self slideFrame:YES];
}

-(IBAction) slideFrameDown;
{
    [self slideFrame:NO];
}

-(void) slideFrame:(BOOL) up
{
    const int movementDistance = 125; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - starRating delegates

- (void)starRatingControl:(StarRatingControl *)control didUpdateRating:(NSUInteger)rating {
	_ratingLabel.text = [_ratingLabels objectAtIndex:rating];
    [self setRate:rating];
}

- (void)starRatingControl:(StarRatingControl *)control willUpdateRating:(NSUInteger)rating {
	_ratingLabel.text = [_ratingLabels objectAtIndex:rating];
    [self setRate:rating];
}


@end
