//
//  GraphMyExpensesViewController.m
//  Shoestring
//
//  Created by mark on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "GraphMyExpensesViewController.h"
#import "GraphCompareViewController.h"
#import "CPTImageLayer.h"
#import "Categories.h"

@interface GraphMyExpensesViewController ()

@property (nonatomic, strong) NSMutableArray *averageDailyValues;

@end

@implementation GraphMyExpensesViewController

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
    int days = self.periodSlider.value;
    self.periodLabel.text = [NSString stringWithFormat:(days>1)?@"%d days":@"%d day",days];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hostView.hostedGraph = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Pass Managed Object Context to Compare View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CompareSegue"])
    {
        GraphCompareViewController *compareVC = [segue destinationViewController];
        compareVC.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - Chart behaviour
-(void)initPlot
{
    [self getAverageValues:15];
    
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configureChart];
}

-(void)configureGraph
{
    // 1 - Create and initialize graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    // 2 - Set up text style
    /*CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
     textStyle.color = [CPTColor grayColor];
     textStyle.fontName = @"Helvetica-Bold";
     textStyle.fontSize = 20.0f;*/
    // 3 - Configure title
    /*NSString *title = @"My Budget";
     graph.title = title;
     graph.titleTextStyle = textStyle;
     graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
     graph.titleDisplacement = CGPointMake(0.0f, -12.0f);*/
}

-(void)configureChart
{
    // 1 - Get reference to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = self.hostView.bounds.size.width * 0.3;
    pieChart.identifier = graph.title;
    //pieChart.startAngle = M_PI_2;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    //pieChart.labelOffset = -50.0f;
    //pieChart.endAngle = 2*M_PI;
    
    // 3 - Create shadow
    CPTMutableShadow *shadow = [[CPTMutableShadow alloc] init];
    shadow.shadowBlurRadius = 5.0;
    shadow.shadowColor = [CPTColor colorWithComponentRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    pieChart.shadow = shadow;
    
    // Add animation
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"endAngle"];
    anim.duration = 1.0f;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //anim.removedOnCompletion = NO;
    //anim.fillMode = kCAFillModeForwards;
    anim.toValue = [NSNumber numberWithFloat:M_PI_2];
    anim.fromValue = [NSNumber numberWithFloat:2*M_PI+M_PI_2];
    [pieChart addAnimation:anim forKey:@"grow"];
    
    anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.duration = 1.0f;
    //anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    [pieChart addAnimation:anim forKey:@"fadeIn"];
    
    // 3 - Add chart to graph
    [graph addPlot:pieChart];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 5;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if (CPTPieChartFieldSliceWidth == fieldEnum)
    {
        if (idx < 5)
            return _averageDailyValues[idx];
        
        float f = 0.0;
        switch (idx) {
            case 0:
                f = 30.0;
                break;
            case 1:
                f = 21.0;
                break;
            case 2:
                f = 16.0;
                break;
            case 3:
                f = 14.0;
                break;
            case 4:
                f = 19.0;
                break;
        }
        return [NSDecimalNumber numberWithFloat:f];
    }
    return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    NSString *iconName = @"";
    switch (idx) {
        case 0:
            iconName = @"cat0.png";
            break;
        case 1:
            iconName = @"cat1.png";
            break;
        case 2:
            iconName = @"cat2.png";
            break;
        case 3:
            iconName = @"cat3.png";
            break;
        case 4:
            iconName = @"cat4.png";
            break;
        default:
            break;
    }
    CPTImageLayer *layer = [[CPTImageLayer alloc] initWIthImage:[UIImage imageNamed:iconName]];
    
    return layer;
}

#pragma mark - CPTPieChartDataSource methods
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    switch (idx) {
        case 0:
            return [CPTFill fillWithColor:[Categories getColorFor:0]];
            break;
        case 1:
            return [CPTFill fillWithColor:[Categories getColorFor:1]];
            break;
        case 2:
            return [CPTFill fillWithColor:[Categories getColorFor:2]];
            break;
        case 3:
            return [CPTFill fillWithColor:[Categories getColorFor:3]];
            break;
        case 4:
            return [CPTFill fillWithColor:[Categories getColorFor:4]];
            break;
        default:
            return nil;
    }
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx { return 10.0; };


- (IBAction)periodChanged:(id)sender
{
    UISlider *slider = sender;
    int days = slider.value;
    self.periodLabel.text = [NSString stringWithFormat:(days>1)?@"%d days":@"%d day",days];
    [self getAverageValues:days];
    [self.hostView.hostedGraph reloadData];
}

@end
