//
//  AddExpenseViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddExpenseViewController.h"
#import "DayViewController.h"
#import "CloudService.h"
#import "Categories.h"


@interface AddExpenseViewController ()

@end

@implementation AddExpenseViewController


@synthesize managedObjectContext;

@synthesize categoryView;
@synthesize btnView;

@synthesize currentCategory;
@synthesize itemNameField,placeNameField,amountField,savingTipField, rate;
@synthesize currentExpense;

@synthesize starRatingControl = _starRatingControl;
@synthesize ratingLabel = _ratingLabel;
@synthesize ratingLabels = _ratingLabels;

@synthesize currentLatitude, currentLongitude;
@synthesize locationManager = _locationManager;

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
    
    
    //set delegates for keyboard dismissal
    [itemNameField setDelegate:self];
    [placeNameField setDelegate:self];
    [amountField setDelegate:self];
    [savingTipField setDelegate:self];
    
    [itemNameField setTag:0];
    [placeNameField setTag:1];
    
    // add the category buttons
    btnView = [[CategoryButtons alloc] init];
    [btnView setDelegate:self];
    CGRect bounds = [[self view] bounds];
    [btnView setCenter: CGPointMake(bounds.size.width/2, 160)];
    [categoryView addSubview:btnView];
    [btnView setCategoryTitle:@"Please select..."];
    
       [[UIApplication sharedApplication].keyWindow bringSubviewToFront:autocompleteTableView];
    
    //starRatings
    _ratingLabels = [NSArray arrayWithObjects:@"Unrated", @"not great", @"Ok", @"not bad", @"really good", @"great deal!", nil];
	
	[[self starRatingControl] setDelegate:self];
}

-(void) viewWillAppear:(BOOL)animated {

    [self startLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Method: prepare to Segue - either addExpense or viewExpense
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"addMapLocation"]) {
        AddMapViewController *amvc = (AddMapViewController*)[segue destinationViewController];
        
        [amvc setDelegate:self];

        [amvc setCurrentLatitude:[self movingLatitude]];
        [amvc setCurrentLongitude:[self movingLongitude]];
        
        [[self locationManager] stopUpdatingLocation];
    }
}


- (IBAction)cancel:(id)sender {
    [[self delegate] addExpenseViewControllerDidCancel: [self currentExpense]];
}

- (IBAction)save:(id)sender {
    
    //assigns values to the current expense object and calls the delegate method to save the context (in DayViewController)
    
    NSString *errorMessage;
    NSNumberFormatter *formatString = [[NSNumberFormatter alloc]init];
    NSNumber *amount = [formatString numberFromString:[amountField text]];
    
    if (itemNameField.text.length == 0)
        errorMessage = @"Please enter a name!";
    else if (placeNameField.text.length == 0)
        errorMessage = @"Please enter a place!";
    else if (![currentCategory isKindOfClass:[NSString class]] || [currentCategory length]==0)
        errorMessage = @"Please select a category!";
    else if (!amount || !([amount floatValue]>0.0f))
        errorMessage = @"Please enter a valid amount!";
    else if (!(currentLatitude && currentLongitude))
        errorMessage = @"Please select a location!";
    
    if (errorMessage)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        [[self currentExpense]setCategory:currentCategory];
        [[self currentExpense]setItemName:[itemNameField text]];
        [[self currentExpense]setPlaceName:[placeNameField text]];
        
        NSNumberFormatter *formatString = [[NSNumberFormatter alloc]init];
        [[self currentExpense]setAmount: [formatString numberFromString:[amountField text]]];
        
        [[self currentExpense]setSavingTip:[savingTipField text]];
        [[self currentExpense]setRating: [NSNumber numberWithInt: rate]];
        //[[self currentExpense]setDate:[self getTodaysDate]];
        [[self currentExpense]setLatitude:[self currentLatitude]];
        [[self currentExpense]setLongitude:[self currentLongitude]];
        
        // Save recommendation
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (appDelegate.loggedIn && savingTipField.text.length > 0 && self.currentLatitude && self.currentLatitude && self.currentLongitude)
        {
            CloudService *cloudService = [CloudService getInstance];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentLatitude.doubleValue longitude:self.currentLongitude.doubleValue];
            [cloudService addRecommendationFor:placeNameField.text location:location rating:[NSNumber numberWithInt:rate] comment:savingTipField.text category:[Categories getIndexFor:currentCategory] completion:^(NSError *error) {}];
        }
        
        [[self delegate] addExpenseViewControllerDidSave];
    }
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


-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self initialiseAutocomplete: textField];
}


- (IBAction)dismissKeyboard:(id)sender {
    
    
    [[self view] endEditing:YES];
    [autocompleteTableView setHidden:YES];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [autocompleteTableView setHidden:YES];
    [btnView setHidden:NO];
    return YES;
}


#pragma mark AutoComplete and UITextFieldDelegate methods

-(void)initialiseAutocomplete: (UITextField*) textField {
    
    if([textField tag] == 0){
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, 80) style:UITableViewStylePlain];
    } else {
    autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, 320, 80) style:UITableViewStylePlain];
    [btnView setHidden:YES];
    }
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    [autocompleteTableView setHidden:YES];
    [self.view addSubview:autocompleteTableView];
    
    
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:autocompleteTableView];
    
    //create the list of names with a method call
    self.itemNames = [self createAutocompleteList: [textField tag]];
    
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
    
    if([itemNameField isEditing]) {
        itemNameField.text = selectedCell.textLabel.text;
    }
    if([placeNameField isEditing]) {
      placeNameField.text = selectedCell.textLabel.text;
    }
    
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
    const int movementDistance = 127; // tweak as needed
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

#pragma mark - Location manager


- (IBAction)findLocation:(id)sender {
    
}

- (IBAction)useCurrentLocation:(id)sender {
    [self setCurrentLatitude:[self movingLatitude]];
    [self setCurrentLongitude:[self movingLongitude]];
}

-(void) startLocationManager {
    
    [self setLocationManager: [CLLocationManager new]];
    
    [[self locationManager]setDelegate:self];
    [[self locationManager] setDesiredAccuracy: kCLLocationAccuracyBest];
    [[self locationManager] setDistanceFilter:kCLDistanceFilterNone];
    [[self locationManager] startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation;
    
    if([locations count] > 1) {
        oldLocation = [locations objectAtIndex:[locations count] - 1];
    } else {
        oldLocation = nil;
    }
    
    CLLocationCoordinate2D coord = [newLocation coordinate];
    [self setMovingLatitude: [NSNumber numberWithFloat: coord.latitude]];
    [self setMovingLongitude: [NSNumber numberWithFloat: coord.longitude]];
}

-(void)addMapViewControllerDidFinish:(AddMapViewController *)addMapViewController {
    
    [self setCurrentLatitude:[addMapViewController currentLatitude]];
    [self setCurrentLongitude:[addMapViewController currentLongitude]];
    
   [self dismissViewControllerAnimated:YES completion:nil];
 
}

-(NSMutableArray*) createAutocompleteList: (int) textFieldTag {
    
    NSMutableArray *autoList;
    
    NSArray *categoryNames = [[NSArray alloc] initWithObjects:@"Accommodation", @"Food", @"Travel", @"Entertainment", @"Shopping", nil];
    
    NSString *category = [[btnView categoryLabel]text];
    
    if(textFieldTag == 0) {
        
    if ([category isEqualToString:[categoryNames objectAtIndex:0]]) {
        autoList = [[NSMutableArray alloc]initWithObjects:@"dorm",@"room", @"hotel", nil];
        
    }   else if ([category isEqualToString:[categoryNames objectAtIndex:1]]) {
        autoList = [[NSMutableArray alloc]initWithObjects:@"burger", @"lunch",@"breakfast", @"dinner", nil];
        
    }   else if ([category isEqualToString:[categoryNames objectAtIndex:2]]) {
        autoList = [[NSMutableArray alloc]initWithObjects:@"bus", @"train",@"ferry", nil];
        
    }   else if ([category isEqualToString:[categoryNames objectAtIndex:3]]) {
        autoList = [[NSMutableArray alloc]initWithObjects:@"beers", @"drinks", @"party", @"cover charge", nil];
        
    }   else {
        autoList = [[NSMutableArray alloc]initWithObjects:@"groceries", @"personal items", @"gifts", @"souvenirs", nil];
      }
    } else if (textFieldTag == 1){

        //get the favourites and place in an NSMutableArray e.g
         autoList = [[NSMutableArray alloc] initWithObjects:@"Aromas", @"City Backpackers", @"Gerbanos", @"Zen coffee", @"YHA roma st", @"Coles Queen st Mall", nil];

    }

return autoList;
}

@end
