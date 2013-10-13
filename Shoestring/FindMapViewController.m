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

@synthesize addressFromFT,phoneFromFT,nameFromFT,ratingFromFT, findMapView = _findMapView;


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
            placeRegion.span.longitudeDelta = 0.30f;
            placeRegion.span.latitudeDelta = 0.30f;
            [self.findMapView setRegion:placeRegion animated:NO];
            
            Annotation *annPlace= [[Annotation alloc]initWithPosition:placeAddress];
            
            annPlace.title = nameFromFT;
            annPlace.subtitle = [NSString stringWithFormat:@"RatingStar from Yelp: %@\n Phone:%@", ratingFromFT, phoneFromFT];
            
            [self.findMapView addAnnotation:annPlace];


            NSLog(@"lat,lon: %f ,%f", placeAddress.latitude, placeAddress.longitude);
        }
        else {
            NSLog(@"No Area of Interest Was Found");
        }
    }];

}



@end
