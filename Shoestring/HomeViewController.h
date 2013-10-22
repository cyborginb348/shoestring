//
//  HomeViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Favourite.h"

@interface HomeViewController : UIViewController
<NSFetchedResultsControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Favourite *favourite;

@property (weak, nonatomic) IBOutlet MKMapView *homeMapView;

@end
