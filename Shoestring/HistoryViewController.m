//
//  HistoryViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "HistoryViewController.h"
#import "DayViewController.h"
#import "AppDelegate.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

@synthesize selectedDate;

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

-(void) viewWillAppear:(BOOL)animated {
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Method: prepare to Segue - either addExpense or viewExpense
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"historyDetail"]) {
        
        DayViewController *dvc= (DayViewController*) [segue destinationViewController];

        //get the current index path, cell, text
        NSIndexPath *indexPath = [[self tableView]indexPathForSelectedRow];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        NSString *myDate = [[cell textLabel] text];
        
        //set the NSDate field
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"EEEE MMM d yyyy"];
        NSDate *dateFromString = [[NSDate alloc]init];
        dateFromString = [dateFormatter dateFromString:myDate];
        [self setSelectedDate:dateFromString];

        [dvc setCurrentDate:[self selectedDate]];
        [dvc setManagedObjectContext:[self managedObjectContext]];
        
        // Remove 'Select Date' button
        [dvc.navigationItem setLeftBarButtonItem:nil];
    
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self fetchedResultsController] sections] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell with the name of the item expense
    id <NSFetchedResultsSectionInfo> secInfo = [[[self fetchedResultsController]sections]objectAtIndex:indexPath.row];
    Expense *expense = [[secInfo objects] firstObject];
    
    [[cell textLabel] setText:[self formatDate:[expense date]]];
    [[cell detailTextLabel]setText:[self getTotal:[expense date]]];
    
    NSLog(@"total for day%@",[self getTotal:[expense date]]);
    
    return cell;
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView* header = [[UIView alloc]init];
//    return header;
//}
//
//-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return[[[[self fetchedResultsController]sections]objectAtIndex:section]name];
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *context = [self managedObjectContext];
        id <NSFetchedResultsSectionInfo> secInfo = [[[self fetchedResultsController]sections]objectAtIndex:indexPath.row];
        
        for (Expense *expense in [secInfo objects])
        {
            [context deleteObject:expense];
        }
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error! %@", error);
        }
        
        // Update data in table
        if(![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Error! %@", error);
            abort();
        }
        [[self tableView] reloadData];
    }
}

/*
 Method to begin updates on fetched results changes
 */
/*-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView]beginUpdates];
}*/

/*
 Method to end updates on fetched results changes
 */
/*-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView]endUpdates];
}*/

/*
 Method to end updates on fetched results changes update/delete/move
 */
/*-(void)controller:(NSFetchedResultsController *) controller didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = [self tableView];
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
          
            break;
            
        case NSFetchedResultsChangeUpdate: {
            Expense *changedExpense = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            //get the date as a string ie NSDate to NSString required date format
           [[cell textLabel]setText:[self formatDate:[changedExpense date]]];
            
            //cell.textLabel.text = @"test";
           
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}*/




#pragma mark -
#pragma mark Fetched Results Controller

-(NSFetchedResultsController*) fetchedResultsController {
    
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense"
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[self managedObjectContext] sectionNameKeyPath:@"date"
                                                                               cacheName:nil];
    
    //set this class as the delegate for the fetchedResults controller
    //[_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}


//-(NSNumber*)calculateTotal: (NSDate*) date forManagedObjectContext: (NSManagedObjectContext*) managedObjectContext {


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - format Date

-(NSString*) formatDate: (NSDate*) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //convert NSDate to format we want...
    [dateFormatter setDateFormat:@"EEEE MMMM d yyyy"];
    return [dateFormatter stringFromDate:date];
}

-(NSString*) getTotal: (NSDate*) date {
    
    DayViewController *dvc = [[DayViewController alloc] init];
    
    NSNumber *total = [dvc calculateTotal:date forManagedObjectContext: [self managedObjectContext]];
    
    return [NSString stringWithFormat:@"total $%@", total];
    
}



@end
