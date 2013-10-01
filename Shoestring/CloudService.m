//
//  CloudService.m
//  AzureTest
//
//  Created by Yannick Schillinger on 21/09/13.
//  Copyright (c) 2013 Yannick Schillinger. All rights reserved.
//

#import "CloudService.h"

#pragma mark * CloudService Private Interface

@interface CloudService() <MSFilter>

@property (nonatomic, strong) MSTable *expenseTable;
@property (nonatomic, strong) MSTable *recommendationTable;
@property (nonatomic) NSInteger busyCount;

- (void)displayMessage:(NSString*)message title:(NSString*)title;
- (void)displayError:(NSError*)error;
- (void)handleRequest:(NSURLRequest *)request next:(MSFilterNextBlock)next response:(MSFilterResponseBlock)response;

@end

#pragma mark * CloudService Implementation

@implementation CloudService

+ (CloudService *)getInstance
{
    static CloudService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ service = [[CloudService alloc] init]; });
    return service;
}

- (CloudService *)init
{
    self = [super init];
    
    if (self)
    {
        self.client = [[MSClient clientWithApplicationURLString:@"https://cyborg.azure-mobile.net/" applicationKey:@"PGCAoXkwACSNtNEsKFLSFprCTNzEgS31"] clientWithFilter:self];
        
        self.expenseTable = [self.client tableWithName:@"Expense"];
        self.recommendationTable = [self.client tableWithName:@"Recommendation"];
    }
    
    return self;
}

- (void)addDailyExpenseOn:(NSDate*)date location:(CLLocation*)location category:(NSNumber*)category amount:(NSNumber*)amount completion:(CompletionBlock)completion
{
    if (self.client.currentUser != nil)
    {
        //NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:expense.dict];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
             {
                 //[self displayError:error];
                 completion(error);
             }
             else
             {
                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
                 [dict setObject:date forKey:@"date"];
                 [dict setObject:category forKey:@"category"];
                 [dict setObject:amount forKey:@"amount"];
                 
                 CLPlacemark *placemark = placemarks[0];
                 [dict setObject:placemark.locality forKey:@"city"];
                 [dict setObject:placemark.administrativeArea forKey:@"state"];
                 [dict setObject:placemark.country forKey:@"country"];
                 
                 
                 [self.expenseTable insert:dict completion:^(NSDictionary *result, NSError *error)
                  {
                      if (error)
                      {
                          //[self displayError:error];
                          completion(error);
                      }
                      else
                      {
                          completion(nil);
                      }
                  }];
             }
         }];
    }
    else
    {
        NSError *loginError = [NSError errorWithDomain:@"cloudServiceDomain" code:100 userInfo:@{NSLocalizedDescriptionKey: @"You need to log in to add expenses."}];
        completion(loginError);
        //[self displayMessage:@"You need to log in to add expenses!" title:@"An error occurred."];
    }
}

- (void)addRecommendationFor:(NSString*)name location:(CLLocation*)location rating:(NSNumber*)rating comment:(NSString*)comment category:(NSNumber*)category completion:(CompletionBlock)completion
{
    if (self.client.currentUser != nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:9];
        [dict setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [dict setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        [dict setObject:name forKey:@"name"];
        [dict setObject:rating forKey:@"rating"];
        [dict setObject:comment forKey:@"comment"];
        [dict setObject:category forKey:@"category"];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
             {
                 //[self displayError:error];
                 completion(error);
             }
             else
             {
                 CLPlacemark *placemark = placemarks[0];
                 [dict setObject:placemark.locality forKey:@"city"];
                 [dict setObject:placemark.administrativeArea forKey:@"state"];
                 [dict setObject:placemark.country forKey:@"country"];
                 
                 [self.recommendationTable insert:dict completion:^(NSDictionary *result, NSError *error)
                  {
                      if (error)
                      {
                          //[self displayError:error];
                          completion(error);
                      }
                      else
                      {
                          completion(nil);
                      }
                  }];
             }
         }];
    }
    else
    {
        NSError *loginError = [NSError errorWithDomain:@"cloudServiceDomain" code:100 userInfo:@{NSLocalizedDescriptionKey: @"You need to log in to add a recommendation."}];
        completion(loginError);
        //[self displayMessage:@"You need to log in to add expenses!" title:@"An error occurred."];
    }
}

- (void)busy:(BOOL)busy
{
    // assumes always executes on UI thread
    if (busy)
    {
        if (self.busyCount == 0 && self.busyUpdate != nil)
        {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil)
        {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void)getAverageFor:(CLLocation*)location completion:(void (^) (NSDictionary*, NSString*, NSError*))completion
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             //[self displayError:error];
             completion(nil, nil, error);
         }
         
         CLPlacemark *placemark = placemarks[0];
         [self.client invokeAPI:@"average" body:nil HTTPMethod:@"GET" parameters:@{@"city":placemark.locality,@"state":placemark.administrativeArea,@"country":placemark.country} headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error)
          {
              if (error)
              {
                  //[self displayError:error];
                  completion(nil, nil, error);
              }
              else
              {
                  if ([result isKindOfClass:[NSArray class]])
                  {
                      NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
                      NSInteger category = 0;
                      NSString *place;
                      for (NSDictionary *row in result)
                      {
                          if ([[row objectForKey:@"category"] isKindOfClass:[NSNumber class]] && [[row objectForKey:@"average"] isKindOfClass:[NSNumber class]])
                          {
                              category = [(NSNumber*)[row objectForKey:@"category"] integerValue];
                              place = [row objectForKey:@"place"];
                              //[resultArray setObject:[row objectForKey:@"average"] atIndexedSubscript:category];
                              [resultDictionary setObject:[row objectForKey:@"average"] forKey:[row objectForKey:@"category"]];
                              
                              //NSLog(@"Result Dictionary: %@", resultDictionary);
                              //NSLog(@"Value for cat. 3: %@", [resultDictionary objectForKey:@3]);
                          }
                          else
                          {
                              // maybe handle this case
                          }
                      }
                      
                      completion(resultDictionary, place, nil);
                  }
                  else
                  {
                      NSError *responseError = [NSError errorWithDomain:@"cloudServiceDomain" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Bad response from server."}];
                      completion(nil, nil, responseError);
                      //[self displayMessage:@"Bad response." title:@"An error occurred."];
                  }
              }
          }];
     }];
}

-(void)getRecommendationsFor:(CLLocation*)location category:(NSNumber*)category maxDistance:(NSNumber*)maxDistance completion:(void (^) (NSArray*, NSError*))completion
{
    [self.client invokeAPI:@"recommendations" body:nil HTTPMethod:@"GET" parameters:@{@"latitude":[NSNumber numberWithDouble:location.coordinate.latitude],@"longitude":[NSNumber numberWithDouble:location.coordinate.longitude],@"category":category,@"maxdistance":maxDistance} headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error)
     {
         if (error)
         {
             //[self displayError:error];
             completion(nil, error);
         }
         else
         {
             if ([result isKindOfClass:[NSArray class]])
             {
                 completion(result, nil);
             }
             else
             {
                 NSError *responseError = [NSError errorWithDomain:@"cloudServiceDomain" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Bad response from server."}];
                 completion(nil, responseError);
                 //[self displayMessage:@"Bad response." title:@"An error occurred."];
             }
         }
     }];
}

// display a message in an UIAlertView
- (void)displayMessage:(NSString*)message title:(NSString*)title
{
    dispatch_async(dispatch_get_main_queue(),^{
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    });
}

// display a given NSError in an UIAlertView
- (void)displayError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(),^{
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark * MSFilter protocol methods

- (void)handleRequest:(NSURLRequest *)request next:(MSFilterNextBlock)next response:(MSFilterResponseBlock)response
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *innerResponse, NSData *data, NSError *error)
    {
        [self busy:NO];
        response(innerResponse, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    next(request, wrappedResponse);
}

@end
