//
//  FindMapViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "Favourite.h"

@interface FindMapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) NSString *addressFromFT;
@property (nonatomic, strong) NSString *ratingFromFT;
@property (nonatomic, strong) NSString *nameFromFT;
@property (nonatomic, strong) NSString *phoneFromFT;

@property (weak, nonatomic) IBOutlet MKMapView *findMapView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Favourite *currentFavourite;

- (IBAction)saveFavourite:(id)sender;

@end
