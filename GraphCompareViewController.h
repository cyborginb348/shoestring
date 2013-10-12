//
//  GraphCompareViewController.h
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GraphCompareViewController : UIViewController <CPTBarPlotDataSource, MBProgressHUDDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic) MBProgressHUD *HUD;

- (IBAction)periodChanged:(id)sender;

@end
