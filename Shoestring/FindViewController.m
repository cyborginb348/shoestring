//
//  FindViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "FindViewController.h"

@interface FindViewController ()

@end

@implementation FindViewController

@synthesize categoryView, currentCategory;

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
	
    // add the category buttons
    CategoryButtons *btnView = [[CategoryButtons alloc] init];
    [btnView setDelegate:self];
    CGRect bounds = [[self view] bounds];
    [btnView setCenter: CGPointMake(bounds.size.width/2, 160)];
    [categoryView addSubview:btnView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CategoryButton Actions

-(void) buttonView: (CategoryButtons*) buttonView changedCategory: (NSString*)newCategory {
    currentCategory = newCategory;
}

@end
