//
//  CPTImageLayer.m
//  CorePlotDemo
//
//  Created by Yannick Schillinger on 11/09/2013.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import "CPTImageLayer.h"

@implementation CPTImageLayer

@synthesize image=_image;

-(id)initWIthImage:(UIImage *)image
{
    if (self = [super initWithFrame:CGRectZero])
    {
        [self setImage:image];
        [self setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    
    return self;
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGContextDrawImage(ctx, self.bounds, _image.CGImage);
}


@end
