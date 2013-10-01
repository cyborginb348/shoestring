//
//  Favourite.h
//  Shoestring
//
//  Created by mark on 16/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favourite : NSManagedObject

@property (nonatomic, retain) NSString * favouritePlace;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
