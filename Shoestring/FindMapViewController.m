//
//  FindMapViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "FindMapViewController.h"
#import "Annotation.h"

@interface FindMapViewController ()
@end

@implementation FindMapViewController

@synthesize currentFavourite;
@synthesize managedObjectContext;

@synthesize addressFromFT,phoneFromFT,nameFromFT,ratingFromFT;
@synthesize findMapView = _findMapView;


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
	// Do any additional setup after loading the view.
    [self.findMapView.delegate self];
    [self.findMapView setShowsUserLocation:YES];
    [self updateMap];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appDelegate managedObjectContext];

    //create new favourite managed object
    currentFavourite = (Favourite*) [NSEntityDescription insertNewObjectForEntityForName:@"Favourite"
            inManagedObjectContext:[self managedObjectContext]];
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 500, 500);
    [self.findMapView setRegion:region animated:YES];
}


-(void)updateMap{
    //find address lat and long
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressFromFT completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if ([placemarks count] > 0) {
            NSString *findedLatitude;
            NSString *findedLongitude;
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D placeAddress = location.coordinate;
            findedLatitude = [NSString stringWithFormat:@"%f", placeAddress.latitude];
            findedLongitude = [NSString stringWithFormat:@"%f", placeAddress.longitude];
            
            MKCoordinateRegion placeRegion;
            placeRegion.center.latitude = placeAddress.latitude;
            placeRegion.center.longitude = placeAddress.longitude;
            placeRegion.span.longitudeDelta = 0.01f;
            placeRegion.span.latitudeDelta = 0.01f;
            [self.findMapView setRegion:placeRegion animated:NO];
            
            Annotation *annPlace= [[Annotation alloc]initWithPosition:placeAddress];
            
            annPlace.title = nameFromFT;
            annPlace.subtitle = [NSString stringWithFormat:@"Rating from Yelp: %@\n Phone:%@", ratingFromFT, phoneFromFT];
            
            [self.findMapView addAnnotation:annPlace];
            
            //save to Coredata
            [[self currentFavourite] setFavouritePlace:[self nameFromFT]];
            [[self currentFavourite] setLatitude:[NSNumber numberWithDouble:placeAddress.latitude]];
            [[self currentFavourite] setLongitude:[NSNumber numberWithDouble:placeAddress.longitude]];

            NSLog(@"lat,lon: %f ,%f", placeAddress.latitude, placeAddress.longitude);
            
        } else {
            NSLog(@"No Area of Interest Was Found");
        }
    }];
      
   }



- (IBAction)saveFavourite:(id)sender {
    
    NSError *error;
    
    if(![[self managedObjectContext] save:&error]) {
        NSLog(@"Error! %@", error);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved"
                                                    message: [NSString stringWithFormat:@"%@ is saved as a favourite.",[self nameFromFT]]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
