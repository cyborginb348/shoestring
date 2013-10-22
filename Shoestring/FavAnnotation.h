//
//  FavAnnotation.h
//  Shoestring
//
//  Created by Yannick Schillinger on 20/10/2013.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "Annotation.h"
#import "Favourite.h"

@interface FavAnnotation : Annotation

@property (strong, nonatomic) Favourite *favourite;

@end
