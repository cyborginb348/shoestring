//
//  AppDelegate.m
//  Shoestring
//
//  Created by mark on 3/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
// test   

#import "AppDelegate.h"
#import "CloudService.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSArray *result;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //create a reference to the tabbar view controller
    tabBarController = (UITabBarController*) [[self window] rootViewController];
    
    
    //set a color for the tab bar - note use mac OS Digitalcolor meter
    UITabBar *tb = [tabBarController tabBar];
    [tb setTintColor: [UIColor colorWithRed:10.0f/255 green:28.0f/255 blue:47.0f/255 alpha:1]];
    
    
    //create references to the navigation controllers for each tab
    UIView *home = (UIView*) [[tabBarController viewControllers]objectAtIndex:0];
    UINavigationController *today = (UINavigationController*)[[tabBarController viewControllers]objectAtIndex:1];
    UINavigationController *find = (UINavigationController*) [[tabBarController viewControllers]objectAtIndex:2];
    UINavigationController *history = (UINavigationController*) [[tabBarController viewControllers]objectAtIndex:3];
    UINavigationController *graphs = (UINavigationController*)[[tabBarController viewControllers]objectAtIndex:4];
    
    
    //create references to first views
    HomeViewController *homeView = (HomeViewController*) home;
    DayViewController *todayView = (DayViewController*)[today topViewController];
    FindViewController  *findView = (FindViewController*)[find topViewController];
    HistoryViewController  *historyView = (HistoryViewController*)[history topViewController];
    GraphMyExpensesViewController  *graphView = (GraphMyExpensesViewController*)[graphs topViewController];

                                                         
    //set references to managed object context for each view
    [homeView setManagedObjectContext:[self managedObjectContext]];
    [todayView setManagedObjectContext:[self managedObjectContext]];
    [findView setManagedObjectContext:[self managedObjectContext]];
    [historyView setManagedObjectContext:[self managedObjectContext]];
    [graphView setManagedObjectContext:[self managedObjectContext]];
    
    
    //[[[CloudService getInstance] client] loginWithProvider:@"facebook" controller:homeView animated:YES completion:^(MSUser *user, NSError *error) {}];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSExpressionDescription* ex = [[NSExpressionDescription alloc] init];
    [ex setExpression:[NSExpression expressionWithFormat:@"@sum.amount"]];
    [ex setExpressionResultType:NSDecimalAttributeType];
    [ex setName:@"sum"];
    
    NSExpressionDescription* exLat = [[NSExpressionDescription alloc] init];
    [exLat setExpression:[NSExpression expressionWithFormat:@"@avg.latitude"]];
    [exLat setExpressionResultType:NSDecimalAttributeType];
    [exLat setName:@"latitude"];
    
    NSExpressionDescription* exLon = [[NSExpressionDescription alloc] init];
    [exLon setExpression:[NSExpression expressionWithFormat:@"@avg.longitude"]];
    [exLon setExpressionResultType:NSDecimalAttributeType];
    [exLon setName:@"longitude"];
    
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"category", @"date", ex, exLat, exLon, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"category", @"date", nil]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSDate *date = [NSDate date];
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synced == NO) AND (date < %@)", date];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    self.result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"count: %d", self.result.count);
    if (self.result.count > 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Share your data" message:@"Are you done entering expenses for yesterday?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
        //[av show];
    }
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index: %d", buttonIndex);
    
    if (buttonIndex == 0)
    {
        CloudService *cloudService = [CloudService getInstance];
        for (NSDictionary *dict in self.result)
        {
            NSLog(@"Bla: %@", dict);
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"latitude"] doubleValue] longitude:[[dict objectForKey:@"longitude"] doubleValue]];
            [cloudService addDailyExpenseOn:[dict objectForKey:@"date"] location:location category:[dict objectForKey:@"category"] amount:[dict objectForKey:@"sum"] completion:^(NSError *error) {
                if (error)
                {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
        }
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Expense"];
        
        NSDate *date = [NSDate date];
        NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
        date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synced == NO) AND (date < %@)", date];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (Expense *expense in result)
        {
            expense.synced = [NSNumber numberWithBool:YES];
        }
        
        [self.managedObjectContext save:&error];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}




- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shoestring" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shoestring.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
