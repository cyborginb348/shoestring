//
//  ExpAnnotation.h
//  Shoestring
//
//  Created by Yannick Schillinger on 25/10/2013.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "Annotation.h"
#import "Expense.h"

@interface ExpAnnotation : Annotation

@property (strong, nonatomic) Expense *expense;

@end
