//
//  Categories.h
//  CorePlotDemo
//
//  Created by Yannick Schillinger on 27/09/13.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Categories : NSObject

+ (NSString*)getNameFor:(NSUInteger)index;
+ (CPTColor*)getColorFor:(NSUInteger)index;
+ (CPTColor*)getTransparentColorFor:(NSUInteger)index;

@end