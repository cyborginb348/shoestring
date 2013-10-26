//
//  FindViewController.h
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CategoryButtons.h"
#import "FindTableViewController.h"

@interface FindViewController : UIViewController
<NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, CategoryButtonsDelegate>{
    CLLocationManager *locationManager;
    
    NSString *passedCategory;
    NSUInteger passedDistance;
    double passedUserLats;
    double passedUserLong;
}
@property (nonatomic, retain) NSString *passedCategory;
@property NSUInteger passedDistance;
@property double passedUserLats;
@property double passedUserLong;

//@property (nonatomic, strong) FindTableViewController *findTableVC;
@property (nonatomic,retain) CLLocationManager *locationManager;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

//displays the category buttons
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (strong,nonatomic) NSString *currentCategory;

//selected distance
- (IBAction)distanceSlider:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *distanceValue;
@property (weak, nonatomic) IBOutlet UILabel *selectedDistance;

//send distance value
@property NSUInteger sendDistance;

//user locatiom
@property double userCurrentLong;
@property double userCurrentLat;

//btn press and find places
- (IBAction)btnFindPlaces:(id)sender;




@end
