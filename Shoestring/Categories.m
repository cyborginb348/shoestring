//
//  Categories.m
//  CorePlotDemo
//
//  Created by Yannick Schillinger on 27/09/13.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import "Categories.h"

@implementation Categories

static NSArray *names;
static NSArray *colors;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        names = @[@"Accommodation", @"Food", @"Travel", @"Entertainment", @"Shopping"];
        colors = @[[CPTColor colorWithComponentRed:0.929 green:0.490 blue:0.192 alpha:1.0],
                   [CPTColor colorWithComponentRed:0.357 green:0.608 blue:0.835 alpha:1.0],
                   [CPTColor colorWithComponentRed:0.647 green:0.647 blue:0.647 alpha:1.0],
                   [CPTColor colorWithComponentRed:0.941 green:0.714 blue:0.0 alpha:1.0],
                   [CPTColor colorWithComponentRed:0.431 green:0.718 blue:0.239 alpha:1.0],
                   [CPTColor colorWithComponentRed:0.267 green:0.447 blue:0.769 alpha:1.0]];
    }
}

+ (NSString*)getNameFor:(NSUInteger)index
{
    return names[index];
}

+ (NSNumber*)getIndexFor:(NSString*)name
{
    for (NSUInteger index = 0; index < names.count; ++index)
    {
        if ([name isEqualToString:names[index]])
            return [NSNumber numberWithUnsignedInt:index];
    }
    return nil;
}

+ (CPTColor*)getColorFor:(NSUInteger)index
{
    return colors[index];
}

+ (CPTColor*)getTransparentColorFor:(NSUInteger)index
{
    return [(CPTColor*)colors[index] colorWithAlphaComponent:0.5];
}

@end