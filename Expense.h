//
//  Expense.h
//  Shoestring
//
//  Created by Yannick Schillinger on 15/10/2013.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Expense : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * savingTip;
@property (nonatomic, retain) NSNumber * synced;

@end
