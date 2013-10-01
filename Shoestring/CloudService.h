//
//  CloudService.h
//  AzureTest
//
//  Created by Yannick Schillinger on 21/09/13.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>
#import "Expense.h"


#pragma mark * Block Definitions

typedef void (^CompletionBlock) (NSError*);
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^BusyUpdateBlock) (BOOL busy);

#pragma mark * CloudService public interface

// A singleton class providing wrapper functions to access the Azure cloud service
// Note that this class shouldn't be instantiated, use getInstance instead
@interface CloudService : NSObject

@property (nonatomic, strong) MSClient *client;
@property (nonatomic, copy) BusyUpdateBlock busyUpdate;

// Retrieves a handle to the static instance of the CloudService class
+ (CloudService*)getInstance;

// Adds a daily expense entry to the database, containing the specified information
- (void)addDailyExpenseOn:(NSDate*)date location:(CLLocation*)location category:(NSNumber*)category amount:(NSNumber*)amount completion:(CompletionBlock)completion;

// Adds a recommendation for a place with the specified information
- (void)addRecommendationFor:(NSString*)name location:(CLLocation*)location rating:(NSNumber*)rating comment:(NSString*)comment category:(NSNumber*)category completion:(CompletionBlock)completion;

// Gets a list containing the average daily expense per category at the specified location
- (void)getAverageFor:(CLLocation*)location completion:(void (^) (NSDictionary*, NSString*, NSError*))completion;

// Gets a list of recommendation close to the specified location
-(void)getRecommendationsFor:(CLLocation*)location category:(NSNumber*)category maxDistance:(NSNumber*)maxDistance completion:(void (^) (NSArray*, NSError*))completion;

@end
