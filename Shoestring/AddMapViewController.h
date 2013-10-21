//
//  AddLocationViewController.h
//  Shoestring
//
//  Created by mark on 6/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "VBAnnotation.h"

@protocol AddMapViewControllerDelegate;

@interface AddMapViewController : UIViewController
<MKMapViewDelegate>

@property (nonatomic, weak) id <AddMapViewControllerDelegate> delegate;
@property (strong, nonatomic) NSNumber *currentLatitude;
@property (strong, nonatomic) NSNumber *currentLongitude;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


- (IBAction)done:(id)sender;

@end

@protocol AddMapViewControllerDelegate
-(void)addMapViewControllerDidFinish:(AddMapViewController*)addMapViewController;
@end