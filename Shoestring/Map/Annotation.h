//
//  Annotation.h
//  Shoestring
//
//  Created by Ka Lok Dicky Chiu on 10/12/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- initWithPosition:(CLLocationCoordinate2D)coords;

@end
