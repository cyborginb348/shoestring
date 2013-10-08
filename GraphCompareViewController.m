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

@property (nonatomic, strong) CPTBarPlot *myPlot;
@property (nonatomic, strong) CPTBarPlot *avgPlot;

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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initPlot];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Chart behaviour
-(void)initPlot
{
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
        if ([plot.identifier isEqual:@"my"])
        {
            float f = 0.0;
            switch (idx) {
                case 0:
                    f = 21.0;
                    break;
                case 1:
                    f = 30.0;
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
        else if ([plot.identifier isEqual:@"avg"])
        {
            float f = 0.0;
            switch (idx) {
                case 0:
                    f = 23.0;
                    break;
                case 1:
                    f = 25.0;
                    break;
                case 2:
                    f = 20.0;
                    break;
                case 3:
                    f = 15.0;
                    break;
                case 4:
                    f = 17.0;
                    break;
            }
            
            return [NSDecimalNumber numberWithFloat:f];
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

@end
