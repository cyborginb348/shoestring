//
//  HomeViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Annotation.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize favourite;
@synthesize fetchedResultsController= _fetchedResultsController;
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
    
    //fetch the manamed object entity
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
    [self updateFavInMapView];
    [self.homeMapView.delegate self];
    [self.homeMapView setShowsUserLocation:YES];
    
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

-(NSFetchedResultsController*) fetchedResultsController {
    
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favourite"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"favouritePlace"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[self managedObjectContext] sectionNameKeyPath: @"favouritePlace"
                                                                               cacheName:nil];
    
    //set this class as the delegate for the fetchedResults controller
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

//map method under here
//http://stackoverflow.com/questions/8325200/how-do-i-show-multiple-custom-annotations-pin-left-icon-loaded-via-plist

-(void) updateFavInMapView{
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    NSLog(@"count fetched data: %i", [fetchedData count]);
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (Favourite *currentFavourite in fetchedData ) {
        NSLog(@"place: %@", [currentFavourite favouritePlace]);
        NSLog(@"latitude: %@", [currentFavourite latitude]);
        NSLog(@"longitude: %@", [currentFavourite longitude]);
        NSLog(@"category: %@", [currentFavourite category]);
        
                
        
        CLLocationCoordinate2D location;
        VBAnnotation *ann;
        
        location.latitude = [[currentFavourite latitude] doubleValue];
        location.longitude = [[currentFavourite longitude] doubleValue];
        ann = [[VBAnnotation alloc] init];
        [ann setCoordinate:location];
        ann.title = [currentFavourite favouritePlace];
        //ann.subtitle = [currentFavourite category];
        [annotations addObject:ann];        
    }
    
    [self.homeMapView addAnnotations:annotations];
}

/*-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    view.pinColor = MKPinAnnotationColorPurple;
    view.enabled = YES;
    view.animatesDrop = YES;
    view.canShowCallout = YES;
    
    return view;
}*/

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 500, 500);
    [self.homeMapView setRegion:region animated:YES];
}

@end
