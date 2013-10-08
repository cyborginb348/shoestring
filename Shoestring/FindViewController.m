//
//  FindViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "FindViewController.h"
#import "FindTableViewController.h"

@interface FindViewController ()

@end

@implementation FindViewController

@synthesize categoryView, currentCategory, selectedDistance, distanceValue, sendDistance, locationManager, userCurrentLat, userCurrentLong, passedUserLong,passedUserLats,passedDistance,passedCategory;

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
	
    // add the category buttons
    CategoryButtons *btnView = [[CategoryButtons alloc] init];
    [btnView setDelegate:self];
    CGRect bounds = [[self view] bounds];
    [btnView setCenter: CGPointMake(bounds.size.width/2, 160)];
    [categoryView addSubview:btnView];
    distanceValue.minimumValue = 500;
    distanceValue.maximumValue = 5000;
    sendDistance = @"500";
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CategoryButton Actions
//delegate method
-(void) buttonView: (CategoryButtons*) buttonView changedCategory: (NSString*)newCategory {
    currentCategory = newCategory;
    NSLog(@"category %@", [self currentCategory]);
}

- (IBAction)distanceSlider:(id)sender {
    double sliDis = (double)distanceValue.value;
    
    int intSliDis = (int)sliDis;
    sendDistance = [NSString stringWithFormat:@"%i", intSliDis];
    
    if(sliDis < 1000)
    {
        NSString *disText = [NSString stringWithFormat:@"%.0fm", sliDis];
        [selectedDistance setText:disText];
    }else{
        double sliDisCount = sliDis / 1000;
        NSString *disText = [NSString stringWithFormat:@"%.2fkm", sliDisCount];
        [selectedDistance setText:disText];
    }
}

- (IBAction)btnFindPlaces:(id)sender {
    [self performSegueWithIdentifier:@"FindVCSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FindVCSegue"]) {
        
        // Get destination view
        FindTableViewController *findTableVC = [segue destinationViewController];
        
        // perpare passing data
        passedCategory = currentCategory;
        passedDistance = sendDistance;
        passedUserLats = userCurrentLat;
        passedUserLong = userCurrentLong;
        
        //passing data here
        [findTableVC setSelectedCat:passedCategory];
        [findTableVC setSelectedDistance:passedDistance];
        [findTableVC setUserLat:passedUserLats];
        [findTableVC setUserLong:passedUserLong];
        
        
        
        [locationManager stopUpdatingLocation];
        
        NSLog(@"selectedCat %@", passedCategory);
        NSLog(@"selectedDistance %@", passedDistance);
        NSLog(@"userLat %@", passedUserLats);
        NSLog(@"userLong %@", passedUserLong);
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        userCurrentLong = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        userCurrentLat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}
@end
