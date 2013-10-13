//
//  VBAnnotation.m
//  MapApp2
//
//  Created by mark on 4/08/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "VBAnnotation.h"


@implementation VBAnnotation

@synthesize coordinate, title, subTitle;


-(id)initWithPosition:(CLLocationCoordinate2D)coords {
    
    if(self = [super init]) {
        [self setCoordinate:coords];
    }
    return self;
}

@end


