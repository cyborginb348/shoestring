//
//  FindMapViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FindMapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) NSString *addressFromFT;
@property (nonatomic, strong) NSString *ratingFromFT;
@property (nonatomic, strong) NSString *nameFromFT;
@property (nonatomic, strong) NSString *phoneFromFT;

@property (weak, nonatomic) IBOutlet MKMapView *findMapView;




@end
