//
//  AddLocationViewController.m
//  Shoestring
//
//  Created by mark on 6/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddMapViewController.h"
#import "AddExpenseViewController.h"

@interface AddMapViewController ()

@end

#define SPAN_VALUE 0.02f;

@implementation AddMapViewController

@synthesize mapView = _mapView;

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
    VBAnnotation *ann = [[VBAnnotation alloc]initWithPosition:location];
    [ann setCoordinate:location];
    ann.title = @"drag pin to new location";
    ann.subTitle = @"touch and drag";
    //add to map
    [[self mapView] addAnnotation:ann];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(id)sender {
    [self.delegate addMapViewControllerDidFinish:self];
}

/*
 Method to create and style an annotation
 */

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (pav == nil) {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
        } else {
        pav.annotation = annotation;
        }
    
    return pav;
}

//Method for draggable pin

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
        {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        [self setCurrentLatitude:[NSNumber numberWithFloat:droppedAt.latitude]];
        [self setCurrentLongitude:[NSNumber numberWithFloat:droppedAt.longitude]];
        }
}


@end
