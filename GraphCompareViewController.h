//
//  GraphCompareViewController.h
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphCompareViewController : UIViewController <CPTBarPlotDataSource>

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

@end
