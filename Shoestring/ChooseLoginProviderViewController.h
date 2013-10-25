//
//  ChooseLoginProviderViewController.h
//  Shoestring
//
//  Created by Yannick Schillinger on 25/10/2013.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseLoginProviderViewControllerDelegate
-(void)chooseLoginProviderViewControllerDidSelect:(NSString*)loginMethod;
@end

@interface ChooseLoginProviderViewController : UITableViewController

@property (nonatomic, weak) id <ChooseLoginProviderViewControllerDelegate> delegate;

@end
