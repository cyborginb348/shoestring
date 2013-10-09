//
//  CPTImageLayer.h
//  CorePlotDemo
//
//  Created by Yannick Schillinger on 11/09/2013.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import "CPTBorderedLayer.h"

@interface CPTImageLayer : CPTBorderedLayer

@property (strong, nonatomic) UIImage *image;

-(id)initWIthImage:(UIImage *)image;

@end
