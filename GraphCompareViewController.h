//
//  GraphCompareViewController.h
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CloudService.h"

@interface GraphCompareViewController : UIViewController <CPTBarPlotDataSource, MBProgressHUDDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UISlider *periodSlider;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
- (IBAction)periodChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@end
