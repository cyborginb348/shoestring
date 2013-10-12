//
//  GraphMyExpensesViewController.h
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphMyExpensesViewController : UIViewController
<CPTPlotDataSource, CPTPieChartDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

- (IBAction)periodChanged:(id)sender;

@end
