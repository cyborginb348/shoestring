//
//  ViewExpenseViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "ViewExpenseViewController.h"

@interface ViewExpenseViewController ()

@end

@implementation ViewExpenseViewController

@synthesize currentExpense;
@synthesize categoryView;
@synthesize currentCategory;
@synthesize toggleIsOn;
@synthesize toggleBtn;

@synthesize ratingLabel = _ratingLabel;
@synthesize ratingLabels = _ratingLabels;
@synthesize starRatingControl = _starRatingControl;
@synthesize setEditable;

@synthesize autocompleteTableView;
@synthesize autocompleteNames,itemNames;
@synthesize itemNameField,placeNameField,amountField,savingTipField;
@synthesize rate;


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

    //add the categoryButton view for the buttons
    CategoryButtons *btnView = [[CategoryButtons alloc] init];
    [btnView setDelegate:self];
    CGRect bounds = [[self view] bounds];
    [btnView setCenter: CGPointMake(bounds.size.width/2, 160)];
    [categoryView addSubview:btnView];
    
    //assign category from segue
    currentCategory = [currentExpense category];
    [btnView setButtonSelected: [self categoryNumberFromString: currentCategory]];
    
    //place text from segue expense object in fields
    [itemNameField setText: [[self currentExpense] itemName]];
    [placeNameField setText: [[self currentExpense] placeName]];
    [amountField setText: [NSString stringWithFormat:@"%@",[[self currentExpense] amount]]];
    [savingTipField setText: [[self currentExpense] savingTip]];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentExpense.latitude.doubleValue longitude:self.currentExpense.longitude.doubleValue];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            CLPlacemark *placemark = placemarks[0];
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
        }
    }];
    
    //set delegates for keyboard dismissal
    [itemNameField setDelegate:self];
    [placeNameField setDelegate:self];
    [amountField setDelegate:self];
    [savingTipField setDelegate:self];
    
    //starRatings
    _ratingLabels = [NSArray arrayWithObjects:@"Unrated", @"not great", @"Ok", @"not bad", @"really good", @"great deal!", nil];
	
    [itemNameField setEnabled:NO];
    [placeNameField setEnabled:NO];
    [amountField setEnabled:NO];
    [savingTipField setEnabled:NO];
    if (savingTipField.text.length==0) savingTipField.hidden = YES;
    [_starRatingControl setEnabled:NO];
    [categoryView setEnabled:NO];
    [self.mapButton setHidden:YES];
    
    [[self starRatingControl] setRating:[[currentExpense rating]integerValue]];
    [[self ratingLabel]setText: [_ratingLabels objectAtIndex:[[currentExpense rating]integerValue]]];
    [self setSetEditable:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method: prepare to Segue - either addExpense or viewExpense
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"editMapLocation"]) {
        AddMapViewController *amvc = (AddMapViewController*)[segue destinationViewController];
        
        [amvc setDelegate:self];
        
        [amvc setCurrentLatitude:self.currentExpense.latitude];
        [amvc setCurrentLongitude:self.currentExpense.longitude];
        
        //[[self locationManager] stopUpdatingLocation];
    }
}

#pragma mark - CategoryButton Actions

-(void) buttonView: (CategoryButtons*) buttonView changedCategory: (NSString*)newCategory {
    currentCategory = newCategory;
}


-(int) categoryNumberFromString: (NSString*) category {
    
    if([category isEqualToString:@"Accommodation"]){
       return 0; 
    } else if ([category isEqualToString:@"Food"]){
        return 1;
    } else if ([category isEqualToString:@"Travel"]){
        return 2;
    } else if ([category isEqualToString:@"Entertainment"]){
        return 3;
    } else {
        return 4;
    }
}

#pragma Editing

- (IBAction)toggle:(id)sender {
    
    if (!toggleIsOn) {
        [self startEditing];
    } else {
        [self doneEditing];
    }
    
    toggleIsOn = !toggleIsOn;
}


- (void)startEditing {
    
    [itemNameField setEnabled:YES];
    [placeNameField setEnabled:YES];
    [amountField setEnabled:YES];
    [savingTipField setEnabled:YES];
    savingTipField.hidden = NO;
    [_starRatingControl setEnabled:YES];
    [categoryView setEnabled:YES];
    [self.mapButton setHidden:NO];
    [self.locationLabel setHidden:YES];
    [self setSetEditable:YES];
    [_starRatingControl setDelegate:self];
    
    [itemNameField setBorderStyle:UITextBorderStyleRoundedRect];
    [placeNameField setBorderStyle:UITextBorderStyleRoundedRect];
    [amountField setBorderStyle:UITextBorderStyleRoundedRect];
    [savingTipField setBorderStyle:UITextBorderStyleRoundedRect];

    [toggleBtn setTitle:@"Done"];
    [toggleBtn setTintColor:[UIColor redColor]];
    
}


- (void)doneEditing {
    
    [itemNameField setEnabled:NO];
    [placeNameField setEnabled:NO];
    [amountField setEnabled:NO];
    [savingTipField setEnabled:NO];
    if (savingTipField.text.length==0) savingTipField.hidden = YES;
    [_starRatingControl setEnabled:NO];
    [categoryView setEnabled:NO];
    [self.mapButton setHidden:YES];
    [self.locationLabel setHidden:NO];
    
    self.locationLabel.text = @"";
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentExpense.latitude.doubleValue longitude:self.currentExpense.longitude.doubleValue];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            CLPlacemark *placemark = placemarks[0];
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
        }
    }];
    
    
    [itemNameField setBorderStyle:UITextBorderStyleNone];
    [placeNameField setBorderStyle:UITextBorderStyleNone];
    [amountField setBorderStyle:UITextBorderStyleNone];
    [savingTipField setBorderStyle:UITextBorderStyleNone];
    

//
    [toggleBtn setTitle:@"Edit"];
    [toggleBtn setTintColor: nil];
  
    //make updates
    [[self currentExpense] setCategory:currentCategory];
    [[self currentExpense] setItemName:[itemNameField text]];
    [[self currentExpense] setPlaceName:[placeNameField text]];
    NSNumber *amt = [NSNumber numberWithInteger:[[amountField text] integerValue]];
    [[self currentExpense] setAmount:amt];
    [[self currentExpense] setSavingTip:[savingTipField text]];
    [[self currentExpense] setRating:[NSNumber numberWithInt: rate]];

    //create AppDelegate reference to call saveContext method
    AppDelegate *myApp = (AppDelegate*) [[UIApplication sharedApplication]delegate];
    [myApp saveContext];
}



#pragma mark - date method
-(NSDate*) getTodaysDate {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
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


-(void)initialiseAutocomplete: (UITextField*) textField {
    

    if([textField tag] == 0){
        autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, 80) style:UITableViewStylePlain];
    } else {
        autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, 320, 80) style:UITableViewStylePlain];
        //[btnView setHidden:YES];
    }
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    [autocompleteTableView setHidden:YES];
    [self.view addSubview:autocompleteTableView];
    
    
    AddExpenseViewController *aevc = [[AddExpenseViewController alloc]init];
    
    //create the list of names with a method call
    self.itemNames = [aevc createAutocompleteList:[textField tag]];
    
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
    
    NSLog(@"edit: %i", setEditable);
	
    if(setEditable) {
    _ratingLabel.text = [_ratingLabels objectAtIndex:rating];
    [self setRate:rating];
    }
}

- (void)starRatingControl:(StarRatingControl *)control willUpdateRating:(NSUInteger)rating {
    
    if(setEditable) {
	_ratingLabel.text = [_ratingLabels objectAtIndex:rating];
    [self setRate:rating];
    }
}

-(void)addMapViewControllerDidFinish:(AddMapViewController *)addMapViewController {
    
    self.currentExpense.latitude = addMapViewController.currentLatitude;
    self.currentExpense.longitude = addMapViewController.currentLongitude;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
