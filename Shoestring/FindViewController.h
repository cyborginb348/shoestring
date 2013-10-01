//
//  FindViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryButtons.h"

@interface FindViewController : UIViewController
<NSFetchedResultsControllerDelegate,CategoryButtonsDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (strong,nonatomic) NSString *currentCategory;



@end
