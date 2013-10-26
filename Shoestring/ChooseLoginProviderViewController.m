//
//  ChooseLoginProviderViewController.m
//  Shoestring
//
//  Created by Yannick Schillinger on 25/10/2013.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "ChooseLoginProviderViewController.h"

@interface ChooseLoginProviderViewController ()

@end

@implementation ChooseLoginProviderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier];
    [self.delegate chooseLoginProviderViewControllerDidSelect:identifier];
}

@end
