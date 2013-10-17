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

@synthesize mapView = _mapView;
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
    
    MKCoordinateRegion region;
    region.center.latitude = [[self currentLatitude] doubleValue];
    region.center.longitude = [[self currentLongitude] doubleValue];
    region.span.latitudeDelta = SPAN_VALUE;
    region.span.longitudeDelta = SPAN_VALUE;
    [[self mapView] setRegion:region animated:NO];
    
    //coordinate
    CLLocationCoordinate2D location;
    location.latitude = [[self currentLatitude] doubleValue];
    location.longitude = [[self currentLongitude] doubleValue];
    
    //annotation
    VBAnnotation *annotation = [[VBAnnotation alloc]initWithPosition:location];
    annotation.title = @"drag to new location";
    annotation.subTitle = @"touch and drag";
    //add to map
    [[self mapView] addAnnotation:annotation];

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
    
    
    return view;
}

//Method for draggable pin

-(void)mapView:(MKMapView *)mapView
annotationView:(MKAnnotationView *)annotationView viewdidChangeDragState:(MKAnnotationViewDragState)newState
  fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
    
    if (newState == MKAnnotationViewDragStateStarting)
    {
        NSLog(@"Beginning drag");
    }
}


@end
