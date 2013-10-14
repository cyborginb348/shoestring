//
//  AddLocationViewController.h
//  Shoestring
//
//  Created by mark on 6/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AddExpenseViewController.h"
#import "VBAnnotation.h"

@interface AddMapViewController : UIViewController
<MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) NSNumber *currentLatitude;
@property (strong, nonatomic) NSNumber *currentLongitude;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
