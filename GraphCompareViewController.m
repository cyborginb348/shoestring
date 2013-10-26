//
//  GraphCompareViewController.m
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "GraphCompareViewController.h"
#import "Categories.h"

@interface GraphCompareViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) CPTBarPlot *myPlot;
@property (nonatomic, strong) CPTBarPlot *avgPlot;

@property (nonatomic, strong) NSDictionary *cloudValues;

@property (nonatomic, strong) NSMutableArray *averageDailyValues;

-(void)getCloudData;
-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;

@end

@implementation GraphCompareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.HUD = [[MBProgressHUD alloc] initWithView:[self view]];
    [[self view] addSubview:self.HUD];
    [self.HUD setDelegate:self];
    [self.HUD setLabelText:@"Loading..."];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
    
    int days = self.periodSlider.value;
    self.periodLabel.text = [NSString stringWithFormat:(days>1)?@"%d days":@"%d day",days];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self initPlot];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getCloudData
{
    [self.HUD show:YES];
    
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:-27.48331 longitude:153.00947]; // REPLACE WITH ACTUAL LOCATION
    [[CloudService getInstance] getAverageFor:_location completion:^(NSDictionary *result, NSString *place, NSError *error)
     {
         [self.HUD hide:YES];
         if (!error)
         {
             self.placeLabel.text = place;
             self.cloudValues = [NSDictionary dictionaryWithDictionary:result];
             [self initPlot];
         }
         else
         {
             NSLog(@"Error: %@", error.localizedDescription);
         }
     }];
}

-(void)getAverageValues:(NSInteger)days
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSExpressionDescription* ex = [[NSExpressionDescription alloc] init];
    [ex setExpression:[NSExpression expressionWithFormat:@"@sum.amount"]];
    [ex setExpressionResultType:NSDecimalAttributeType];
    [ex setName:@"sum"];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"category", @"date", ex, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"category", @"date", nil]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-60*60*24*days];
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date > %@)", date];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
        NSLog(@"%@", [error localizedDescription]);
    else
    {
        float sums[5] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
        int counts[5] = {0, 0, 0, 0, 0};
        
        for (NSDictionary *record in result)
        {
            NSString *category = [record objectForKey:@"category"];
            NSNumber *sum = [record objectForKey:@"sum"];
            if ([category isEqualToString:@"Accommodation"])
            {
                sums[0] += [sum floatValue];
                ++counts[0];
            }
            else if ([category isEqualToString:@"Food"])
            {
                sums[1] += [sum floatValue];
                ++counts[1];
            }
            else if ([category isEqualToString:@"Travel"])
            {
                sums[2] += [sum floatValue];
                ++counts[2];
            }
            else if ([category isEqualToString:@"Entertainment"])
            {
                sums[3] += [sum floatValue];
                ++counts[3];
            }
            else if ([category isEqualToString:@"Shopping"])
            {
                sums[4] += [sum floatValue];
                ++counts[4];
            }
        }
        
        _averageDailyValues = [NSMutableArray array];
        for (int i = 0; i < 5; ++i)
        {
            [_averageDailyValues addObject:[NSNumber numberWithFloat:sums[i]/counts[i]]];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.HUD hide:YES];
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    [_locationManager stopUpdatingLocation];
    _location = newLocation;
    [self getCloudData];
}

#pragma mark - Chart behaviour
-(void)initPlot
{
    [self getAverageValues:15];
    
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph
{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    // 2 - Configure the graph
    //[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 0.0f;
    graph.paddingLeft = 5.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    // 3 - Set up styles
    /*CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
     textStyle.color = [CPTColor grayColor];
     textStyle.fontName = @"Helvetica-Bold";
     textStyle.fontSize = 20.0f;
     // 4 - Configure title
     NSString *title = @"Compare Budget";
     graph.title = title;
     graph.titleTextStyle = textStyle;
     graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
     graph.titleDisplacement = CGPointMake(0.0f, -12.0f);*/
    // 5 - Set up plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(5.0f)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(35.0f)];
}

-(void)configurePlots
{
    // 1 - Set up the two plots
    self.myPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    self.myPlot.identifier = @"my";
    self.avgPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    self.avgPlot.identifier = @"avg";
    // 2 - Set up line style
    //CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    //barLineStyle.lineColor = [CPTColor lightGrayColor];
    //barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = 0.25f;
    NSArray *plots = [NSArray arrayWithObjects:self.myPlot, self.avgPlot, nil];
    for (CPTBarPlot *plot in plots)
    {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(0.25f);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = nil;
        //plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += 1.5*0.25f;
    }
}

-(void)configureAxes
{
    // 1 - Configure style
    //CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    //axisLineStyle.lineWidth = 0.0f;
    //axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.hostView.hostedGraph.axisSet;
    axisSet.hidden = YES;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //axisSet.xAxis.axisLineStyle = axisLineStyle;
    //axisSet.xAxis.hidden = YES;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 5;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (idx < 5))
    {
        if ([plot.identifier isEqual:@"my"] && idx < 5)
        {
            return _averageDailyValues[idx];
        }
        else if ([plot.identifier isEqual:@"avg"])
        {
            return [self.cloudValues objectForKey:[NSNumber numberWithUnsignedInt:idx+1]];
        }
    }
    return [NSDecimalNumber numberWithUnsignedInt:idx];
}

-(CPTFill*)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    if ([barPlot.identifier isEqual:@"avg"])
        return [CPTFill fillWithColor:[Categories getTransparentColorFor:idx]];
    else
        return [CPTFill fillWithColor:[Categories getColorFor:idx]];
}

- (IBAction)periodChanged:(id)sender
{
    UISlider *slider = sender;
    int days = slider.value;
    self.periodLabel.text = [NSString stringWithFormat:(days>1)?@"%d days":@"%d day",days];
    [self getAverageValues:days];
    [self.hostView.hostedGraph reloadData];
}

@end
