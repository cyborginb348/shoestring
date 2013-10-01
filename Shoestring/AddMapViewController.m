//
//  AddLocationViewController.m
//  Shoestring
//
//  Created by mark on 6/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "AddMapViewController.h"

@interface AddMapViewController ()

@end

@implementation AddMapViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
