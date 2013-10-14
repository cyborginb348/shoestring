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
    
    NSLog(@"%@", [self currentLongitude]);
	
    //set delegate for mapview as this controller
    [[self mapView] setDelegate:self];
    
    //set the location from the device
    [self.mapView setShowsUserLocation:YES];
    
    //coordinate
    CLLocationCoordinate2D location;
    location.latitude = [[self currentLongitude] doubleValue];
    location.longitude = [[self currentLatitude] doubleValue];
    //annotation
    VBAnnotation *annotation = [[VBAnnotation alloc]initWithPosition:location];
    annotation.title = @"current location";
    annotation.subTitle = @"touch and drag to new location";
    //add to map
    [[self mapView] addAnnotation:annotation];
    
    //LocationManager
    [self setLocationManager:[CLLocationManager new]];
    [[self locationManager]setDelegate:self];
    [[self locationManager]setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager]setDistanceFilter:kCLDistanceFilterNone];

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
    [view setCanShowCallout:NO];
//    //image button
//    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user-icon.png" ]];
//    [view setLeftCalloutAccessoryView:imageView];
//    [view setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    return view;
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"showing");
    
    CLLocationCoordinate2D location = [userLocation coordinate];
    
    [[self mapView] setCenterCoordinate:location];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 100000, 100000);
    [[self mapView] setRegion:region animated:YES];
}

//allows draggable pin
-(void)mapView:(MKMapView *)mapView
annotationView:(MKAnnotationView *) viewdidChangeDragState:(MKAnnotationViewDragState)newState
  fromOldState:(MKAnnotationViewDragState)oldState {
    
}

-(void)gotoLocation {
    MKCoordinateRegion region;
    CLLocationCoordinate2D center;
    center.latitude = [[self currentLatitude] doubleValue];
    center.longitude = [[self currentLongitude] doubleValue];
    MKCoordinateSpan span;
    span.latitudeDelta = SPAN_VALUE;
    span.longitudeDelta = SPAN_VALUE;
    region.center = center;
    region.span = span;
    [mapView setRegion:region animated:YES];
}

@end
