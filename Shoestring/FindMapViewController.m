//
//  FindMapViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "FindMapViewController.h"
#import "FindViewController.h"
#import "Annotation.h"

@interface FindMapViewController ()
@end

@implementation FindMapViewController

@synthesize currentFavourite;
@synthesize managedObjectContext;

@synthesize category;

@synthesize addressFromFT,phoneFromFT,nameFromFT,ratingFromFT, haveLatLon, lat, lon;
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
    
    haveLatLon = @"NO";
    //NSLog(@"CATEGORY: %@", [self category]);
    
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
            
            lat = [NSNumber numberWithDouble:placeAddress.latitude];
            
            lon = [NSNumber numberWithDouble:placeAddress.longitude];
            
            

            
            haveLatLon = @"YES";
            
            NSLog(@"lat,lon: %f ,%f", placeAddress.latitude, placeAddress.longitude);
            
        } else {
            NSLog(@"No Area of Interest Was Found");

            haveLatLon = @"NO";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message: [NSString stringWithFormat:@"Location didn't show, because %@ havn't provide the geolocation.", nameFromFT]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}



- (IBAction)saveFavourite:(id)sender {
    
    UIAlertView *alert;
    
    if([haveLatLon isEqualToString:@"NO"]){
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message: [NSString stringWithFormat:@"Saving failed, because %@ havn't provide the geolocation.", nameFromFT]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    
    if([haveLatLon isEqualToString:@"YES"]){
        NSError *error;
        
        //save to Coredata
        [[self currentFavourite] setFavouritePlace:[self nameFromFT]];
        [[self currentFavourite] setCategory:[self category]];
        [[self currentFavourite] setLatitude:[self lat]];
        [[self currentFavourite] setLongitude:[self lon]];
        
        
        if(![[self managedObjectContext] save:&error]) {
            NSLog(@"Error! %@", error);
        }
        
        alert = [[UIAlertView alloc] initWithTitle:@"Saved"
                                           message: [NSString stringWithFormat:@"%@ is saved as a favourite %@ location.",[self nameFromFT], [self category]]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    [alert show];
}
@end
