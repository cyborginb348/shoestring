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

@interface HomeViewController ()

@property (nonatomic, strong) FavAnnotation *selectedAnnotation;

-(void)refreshMap;

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
    [self.homeMapView setShowsUserLocation:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshMap];
}

-(void)refreshMap
{
    NSLog(@"BLAAA");
    //fetch the manamed object entity
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
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
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isMemberOfClass:[FavAnnotation class]])
    {
        FavAnnotation *favAnnotation = (FavAnnotation*)annotation;
        
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:favAnnotation reuseIdentifier:@"pin"];
        //view.pinColor = MKPinAnnotationColorPurple;
        view.enabled = YES;
        //view.animatesDrop = YES;
        view.canShowCallout = YES;
        
        NSString *category = favAnnotation.favourite.category;
        
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
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 32, 32)];
        //[deleteButton setTitle:@"Button Title" forState:UIControlStateNormal];
        //[sampleButton setFont:[UIFont boldSystemFontOfSize:20]];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        view.rightCalloutAccessoryView = deleteButton;
        
        return view;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[FavAnnotation class]])
    {
        self.selectedAnnotation = (FavAnnotation*)annotation;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete Favourite" message:[NSString stringWithFormat:@"Are you sure you want to delete '%@'", self.selectedAnnotation.favourite.favouritePlace] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
        [av show];
        NSLog(@"clicked %@", [(FavAnnotation*)annotation favourite].favouritePlace);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && self.selectedAnnotation != nil)
    {
        [self.managedObjectContext deleteObject:self.selectedAnnotation.favourite];
        NSError *error;
        [self.managedObjectContext save:&error];
        
        [self.homeMapView removeAnnotation:self.selectedAnnotation];
    }
    self.selectedAnnotation = nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 500, 500);
    [self.homeMapView setRegion:region animated:YES];
}

@end
