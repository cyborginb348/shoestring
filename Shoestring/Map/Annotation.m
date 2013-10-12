//
//  Annotation.m
//  Shoestring
//
//  Created by Ka Lok Dicky Chiu on 10/12/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize coordinate, title, subtitle;

- initWithPosition:(CLLocationCoordinate2D)coords {
    if (self = [super init]) {
        self.coordinate = coords;
    }
    return self;
}

@end
