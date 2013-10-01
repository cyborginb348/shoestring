//
//  CloudAverage.h
//  Shoestring
//
//  Created by mark on 16/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CloudAverage : NSManagedObject

@property (nonatomic, retain) NSNumber * average;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSString * locationName;

@end
