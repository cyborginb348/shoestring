//
//  AddLocationViewController.m
//  Shoestring
//
//  Created by mark on 6/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddMapViewController.h"

@interface AddMapViewController ()

@end

#define BRIS_LAT -27.395703
#define BRIS_LNG 153.053472
#define SPAN_VALUE 0.02f;

@implementation AddMapViewController

@synthesize mapView;
@synthesize locationManager = _locationManager;

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
	
    //set delegate for mapview as this controller
    [[self mapView] setDelegate:self];
    
    //set the location from the device
    //[self.mapView setShowsUserLocation:YES];
    
    //go to Brisbane location
    [self gotoLocation];
    
    //coordinate
    CLLocationCoordinate2D location;
    location.latitude = BRIS_LAT;
    location.longitude = BRIS_LNG;
    //annotation
    VBAnnotation *annotation = [[VBAnnotation alloc]initWithPosition:location];
    annotation.title = @"My House";
    annotation.subTitle = @"it's up";
    //add to map
    [[self mapView] addAnnotation:annotation];
    
    //LocationManager
    [self setLocationManager:[CLLocationManager new]];
    [[self locationManager]setDelegate:self];
    [[self locationManager]setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager]setDistanceFilter:kCLDistanceFilterNone];
    //start
    [[self locationManager] startUpdatingLocation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    //get reference to AddExpense View controller and save to currentLatitude/longitude
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 Method to create and style an annotation
 */
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //view
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    //pin color
    [view setPinColor:MKPinAnnotationColorPurple];
    [view setEnabled:YES];
    [view setDraggable:YES];
    [view setAnimatesDrop:YES];
    [view setCanShowCallout:YES];
    //image button
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user-icon.png" ]];
    [view setLeftCalloutAccessoryView:imageView];
    [view setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    return view;
}

/*
 Method to provide action when annotation view pressed*/

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"MESSAGE" message:@"you rang" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"showing");
    
    CLLocationCoordinate2D location = [userLocation coordinate];
    
    [[self mapView] setCenterCoordinate:location];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 100000, 100000);
    [[self mapView] setRegion:region animated:YES];
}

//allows draggable pin
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
}

-(void)gotoLocation {
    
    MKCoordinateRegion region;
    
    CLLocationCoordinate2D center;
    center.latitude = BRIS_LAT;
    center.longitude = BRIS_LNG;
    MKCoordinateSpan span;
    span.latitudeDelta = SPAN_VALUE;
    span.longitudeDelta = SPAN_VALUE;
    
    region.center = center;
    region.span = span;
    
    [mapView setRegion:region animated:YES];
    
}

@end
