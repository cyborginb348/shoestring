//
//  HomeViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "FavAnnotation.h"
#import "ExpAnnotation.h"
#import "CloudService.h"

#define kAlertViewSync 1
#define kAlertViewDelete 2

@interface HomeViewController ()

@property (nonatomic, strong) FavAnnotation *selectedAnnotation;
@property (nonatomic, strong) NSArray *result;

-(void)refreshMap;

@end

@implementation HomeViewController

@synthesize favourite;
@synthesize favouritesResultsController= _favouritesResultsController;
@synthesize expensesResultsController= _expensesResultsController;
@synthesize homeMapView = _homeMapView;

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
	
    [self.homeMapView setDelegate:self];
    [self.homeMapView setShowsUserLocation:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // Log in
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedIn)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loginMethod = [defaults stringForKey:@"loginMethod"];
        if (!loginMethod)
            [self performSegueWithIdentifier:@"chooseLogIn" sender:self];
        else if ([loginMethod isEqualToString:@"facebook"] || [loginMethod isEqualToString:@"twitter"] || [loginMethod isEqualToString:@"google"] || [loginMethod isEqualToString:@"microsoftaccount"])
        {
            [defaults setObject:@"nil" forKey:@"loginMethod"];
            [[[CloudService getInstance] client] loginWithProvider:loginMethod controller:self animated:YES completion:^(MSUser *user, NSError *error) {
                if (!error)
                {
                    appDelegate.loggedIn = YES;
                    [defaults setObject:loginMethod forKey:@"loginMethod"];
                    
                    // Check for unsynced expenses
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense"
                                                              inManagedObjectContext:[self managedObjectContext]];
                    [fetchRequest setEntity:entity];
                    
                    NSExpressionDescription* ex = [[NSExpressionDescription alloc] init];
                    [ex setExpression:[NSExpression expressionWithFormat:@"@sum.amount"]];
                    [ex setExpressionResultType:NSDecimalAttributeType];
                    [ex setName:@"sum"];
                    
                    NSExpressionDescription* exLat = [[NSExpressionDescription alloc] init];
                    [exLat setExpression:[NSExpression expressionWithFormat:@"@avg.latitude"]];
                    [exLat setExpressionResultType:NSDecimalAttributeType];
                    [exLat setName:@"latitude"];
                    
                    NSExpressionDescription* exLon = [[NSExpressionDescription alloc] init];
                    [exLon setExpression:[NSExpression expressionWithFormat:@"@avg.longitude"]];
                    [exLon setExpressionResultType:NSDecimalAttributeType];
                    [exLon setName:@"longitude"];
                    
                    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"category", @"date", ex, exLat, exLon, nil]];
                    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"category", @"date", nil]];
                    [fetchRequest setResultType:NSDictionaryResultType];
                    
                    NSDate *date = [NSDate date];
                    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
                    date = [[NSCalendar currentCalendar] dateFromComponents:comps];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synced == NO) AND (date < %@)", date];
                    [fetchRequest setPredicate:predicate];
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
                    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
                    [fetchRequest setSortDescriptors:sortDescriptors];
                    
                    NSError *error;
                    self.result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    
                    NSLog(@"count: %d", self.result.count);
                    if (self.result.count > 0)
                    {
                        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Share your data" message:@"Are you done entering expenses for yesterday?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
                        av.tag = kAlertViewSync;
                        [av show];
                    }
                }
                /*else
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"nil" forKey:@"loginMethod"];
                    [defaults synchronize];
                }*/
            }];
        }
    }
    
    [self refreshMap];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewSync)
    {
        
        if (buttonIndex == 0)
        {
            CloudService *cloudService = [CloudService getInstance];
            for (NSDictionary *dict in self.result)
            {
                NSLog(@"Bla: %@", dict);
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"latitude"] doubleValue] longitude:[[dict objectForKey:@"longitude"] doubleValue]];
                [cloudService addDailyExpenseOn:[dict objectForKey:@"date"] location:location category:[dict objectForKey:@"category"] amount:[dict objectForKey:@"sum"] completion:^(NSError *error) {
                    if (error)
                    {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                }];
            }
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Expense"];
            
            NSDate *date = [NSDate date];
            NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
            date = [[NSCalendar currentCalendar] dateFromComponents:comps];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synced == NO) AND (date < %@)", date];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            for (Expense *expense in result)
            {
                expense.synced = [NSNumber numberWithBool:YES];
            }
            
            [self.managedObjectContext save:&error];
        }
    }
    else if (alertView.tag == kAlertViewDelete)
    {
        if (buttonIndex == 0 && self.selectedAnnotation != nil)
        {
            [self.managedObjectContext deleteObject:self.selectedAnnotation.favourite];
            NSError *error;
            [self.managedObjectContext save:&error];
            
            //[self.homeMapView removeAnnotation:self.selectedAnnotation];
        }
        self.selectedAnnotation = nil;
    }
}

-(void)refreshMap
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showFavourites = [defaults boolForKey:@"showFavourites"];
    BOOL showExpenses = [defaults boolForKey:@"showExpenses"];
    
    //fetch the manamed object entity
    NSError *error = nil;
    if (showFavourites)
    {
        if(![[self favouritesResultsController] performFetch:&error]) {
            NSLog(@"Error! %@", error);
            abort();
        }
    } else _favouritesResultsController = nil;
    if (showExpenses)
    {
        if(![[self expensesResultsController] performFetch:&error]) {
            NSLog(@"Error! %@", error);
            abort();
        }
    } else _expensesResultsController = nil;
    [self updateFavInMapView];
    
    
    /*****************************************************************/
    
    // Get the favourites
    
    /*NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
     NSLog(@"count fetched data: %i", [fetchedData count]);
     
     
     for (Favourite *currentFavourite in fetchedData ) {
     NSLog(@"place: %@", [currentFavourite favouritePlace]);
     NSLog(@"latitude: %@", [currentFavourite latitude]);
     NSLog(@"longitude: %@", [currentFavourite longitude]);
     NSLog(@"category: %@", [currentFavourite category]);
     }*/
    
    /*****************************************************************/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Fetched Results Controller

-(NSFetchedResultsController*) favouritesResultsController {
    
    if(_favouritesResultsController != nil) {
        return _favouritesResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favourite"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"favouritePlace"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    
    _favouritesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[self managedObjectContext] sectionNameKeyPath: @"favouritePlace"
                                                                               cacheName:nil];
    
    //set this class as the delegate for the fetchedResults controller
    [_favouritesResultsController setDelegate:self];
    
    return _favouritesResultsController;
}

-(NSFetchedResultsController*) expensesResultsController {
    
    if(_expensesResultsController != nil) {
        return _expensesResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchLimit:5];
    
    
    _expensesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[self managedObjectContext] sectionNameKeyPath: nil
                                                                               cacheName:nil];
    
    //set this class as the delegate for the fetchedResults controller
    [_expensesResultsController setDelegate:self];
    
    return _expensesResultsController;
}

-(void) updateFavInMapView{
    [self.homeMapView removeAnnotations:self.homeMapView.annotations];
    
    NSArray *fetchedData = [_favouritesResultsController fetchedObjects];
    NSLog(@"count fetched data: %i", [fetchedData count]);
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (Favourite *currentFavourite in fetchedData ) {
        NSLog(@"place: %@", [currentFavourite favouritePlace]);
        NSLog(@"latitude: %@", [currentFavourite latitude]);
        NSLog(@"longitude: %@", [currentFavourite longitude]);
        NSLog(@"category: %@", [currentFavourite category]);
        
                
        
        CLLocationCoordinate2D location;
        FavAnnotation *ann;
        
        location.latitude = [[currentFavourite latitude] doubleValue];
        location.longitude = [[currentFavourite longitude] doubleValue];
        ann = [[FavAnnotation alloc] init];
        [ann setCoordinate:location];
        ann.title = [currentFavourite favouritePlace];
        ann.favourite = currentFavourite;
        ann.subtitle = [currentFavourite category];
        [annotations addObject:ann];        
    }
    
    [self.homeMapView addAnnotations:annotations];
    
    fetchedData = [_expensesResultsController fetchedObjects];
    NSLog(@"count fetched data: %i", [fetchedData count]);
    
    annotations = [[NSMutableArray alloc] init];
    
    for (Expense *currentExpense in fetchedData ) {
        NSLog(@"place: %@", [currentExpense placeName]);
        NSLog(@"latitude: %@", [currentExpense latitude]);
        NSLog(@"longitude: %@", [currentExpense longitude]);
        NSLog(@"category: %@", [currentExpense category]);
        
        
        
        CLLocationCoordinate2D location;
        ExpAnnotation *ann;
        
        location.latitude = [[currentExpense latitude] doubleValue];
        location.longitude = [[currentExpense longitude] doubleValue];
        ann = [[ExpAnnotation alloc] init];
        [ann setCoordinate:location];
        ann.title = [currentExpense placeName];
        ann.expense = currentExpense;
        ann.subtitle = [currentExpense category];
        [annotations addObject:ann];
    }
    
    [self.homeMapView addAnnotations:annotations];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *category;
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    if ([annotation isMemberOfClass:[FavAnnotation class]])
    {
        FavAnnotation *favAnnotation = (FavAnnotation*)annotation;
        category = favAnnotation.favourite.category;
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 32, 32)];
        //[deleteButton setTitle:@"Button Title" forState:UIControlStateNormal];
        //[sampleButton setFont:[UIFont boldSystemFontOfSize:20]];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        view.rightCalloutAccessoryView = deleteButton;
    }
    else if ([annotation isMemberOfClass:[ExpAnnotation class]])
    {
        ExpAnnotation *expAnnotation = (ExpAnnotation*)annotation;
        category = expAnnotation.expense.category;
    }
    else return nil;
    
    
    view.enabled = YES;
    view.canShowCallout = YES;
    if ([category isEqualToString:@"Accommodation"])
    {
        view.image = [UIImage imageNamed:@"ann0.png"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat0.png"]];
    }
    else if ([category isEqualToString:@"Food"])
    {
        view.image = [UIImage imageNamed:@"ann1.png"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat1.png"]];
    }
    else if ([category isEqualToString:@"Travel"])
    {
        view.image = [UIImage imageNamed:@"ann2.png"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat2.png"]];
    }
    else if ([category isEqualToString:@"Entertainment"])
    {
        view.image = [UIImage imageNamed:@"ann3.png"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat3.png"]];
    }
    else if ([category isEqualToString:@"Shopping"])
    {
        view.image = [UIImage imageNamed:@"ann4.png"];
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat4.png"]];
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[FavAnnotation class]])
    {
        self.selectedAnnotation = (FavAnnotation*)annotation;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete Favourite" message:[NSString stringWithFormat:@"Are you sure you want to delete '%@'", self.selectedAnnotation.favourite.favouritePlace] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
        av.tag = kAlertViewDelete;
        [av show];
        NSLog(@"clicked %@", [(FavAnnotation*)annotation favourite].favouritePlace);
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 500, 500);
    [self.homeMapView setRegion:region animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chooseLogIn"])
    {
        ChooseLoginProviderViewController *clpvc = segue.destinationViewController;
        clpvc.delegate = self;
    }
}

-(void)chooseLoginProviderViewControllerDidSelect:(NSString *)loginMethod
{
    NSLog(@"Login method: %@", loginMethod);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:loginMethod forKey:@"loginMethod"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
