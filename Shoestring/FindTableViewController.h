//
//  FindTableViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"
#import "MBProgressHUD.h"

#define CONSUMER_KEY            @"bkBTx2-zuTtDyOdgwcy6hA"
#define CONSUMER_SECRET         @"Zmf4EuQMwAuuJFkdbiLIGCzTp94"
#define ACCESS_TOKEN            @"qHuSrIoZrQ1phNU1JlbvUGv8ZpsMxX98"
#define ACCESS_TOKEN_SECRET     @"Nnu377bADwQ-T3PYnGBWu5g6eag"

@interface FindTableViewController : UITableViewController
<MBProgressHUDDelegate> {
    
    MBProgressHUD  *HUD;
    NSMutableData *_responseData;
    NSMutableArray *businessObjectList;
    
}

@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

@property (nonatomic, strong) NSString *selectedDistance;
@property (nonatomic, strong) NSString *selectedCat;
@property (nonatomic, strong) NSString *userLong;
@property (nonatomic, strong) NSString *userLat;


//array of each business item, e.g. [0]name, address, imageurl;
@property (nonatomic, strong) NSMutableArray *businessObjectList;


@end
