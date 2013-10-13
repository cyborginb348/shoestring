//
//  VBAnnotation.h
//  MapApp2
//
//  Created by mark on 4/08/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VBAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

-initWithPosition:(CLLocationCoordinate2D)coords;

@end
