//
//  TodayViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 5/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "DayViewController.h"



@interface DayViewController ()

@end

@implementation DayViewController

//internal instance variable
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize total;
@synthesize displayDate;


- (void)viewDidLoad
{
    [super viewDidLoad];
   

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    
    //assign today to current dat (if Today tabBar item selected)
    AddExpenseViewController *aevc = [[AddExpenseViewController alloc]init];
    
    NSLog(@"Initial Date %@)", [self displayDate]);
    
    //query the request as the required date
    if([self displayDate] == NULL) {
        [self setDisplayDate:[aevc getTodaysDate]];
    }

    NSLog(@"AFter set Date %@)", [self displayDate]);
    
    
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error! %@", error);
        abort();
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM d"];
    NSString *date = [dateFormatter stringFromDate:[self displayDate]];
    NSLog(@"%@",date);
    
    [self setTitle:date];
    
    [self showTotal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Method: prepare to Segue - either addExpense or viewExpense
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"addExpense"]) {
        AddExpenseViewController *aevc = (AddExpenseViewController*)[segue destinationViewController];
        [aevc setDelegate:self];
        
        //create new expense managed object, and set expense variable in new window being modally segued to...
        Expense *expense = (Expense*) [NSEntityDescription insertNewObjectForEntityForName:@"Expense"
                                                                    inManagedObjectContext:[self managedObjectContext]];
        [aevc setCurrentExpense:expense];
    }
    
    //OR if we are viewing a current cell
    if([[segue identifier] isEqualToString:@"viewExpense"]) {
        
        ViewExpenseViewController *vevc = (ViewExpenseViewController*) [segue destinationViewController];
        NSIndexPath *indexPath  = [[self tableView] indexPathForSelectedRow];
        Expense *selectedExpense = (Expense*) [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [vevc setCurrentExpense:selectedExpense];
    }  
}

#pragma mark - View Control save and cancel

//Method: if cancelled in AddExpenseViewController, then delete context and dismiss controller
-(void)addExpenseViewControllerDidCancel: (Expense*) expenseToDelete {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject: expenseToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Method: save the context and dismiss the view controller
-(void)addExpenseViewControllerDidSave {
    
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    if(![context save:&error]) {
        NSLog(@"Error! %@", error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showTotal];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[[self fetchedResultsController]sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> secInfo = [[[self fetchedResultsController]sections]objectAtIndex:section];
    
    return [secInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *cellIdentifier = @"Cell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell with the name of the item expense
    Expense *expense = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    
    [[cell textLabel]setText:[NSString stringWithFormat:@"$%@  %@",[expense amount],[expense itemName]]];
    [[cell detailTextLabel] setText:[expense placeName]];
    
    return cell;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
    return [[[[self fetchedResultsController]sections]objectAtIndex:section]name];
}


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
        Expense *expenseToDelete = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [context deleteObject: expenseToDelete];
        
        NSError *error = nil;
        if(![context save:&error]) {
            NSLog(@"Error! %@", error);
        }
    }
    [self showTotal];
}



//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//
//
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}


#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

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
    
    //set the query predicate to select the correct display date
   
    NSLog(@"predicate DAte: %@", displayDate);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@",displayDate];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[self managedObjectContext] sectionNameKeyPath: @"category"
                                                                               cacheName:nil];
    
    //set this class as the delegate for the fetchedResults controller
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}


/*
 Method to begin updates on fetched results changes
 */
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView]beginUpdates];
}

/*
 Method to end updates on fetched results changes
 */
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView]endUpdates];
}

/*
 Method to end updates on fetched results changes update/delete/move
 */
-(void)controller:(NSFetchedResultsController *) controller didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = [self tableView];
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self showTotal];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self showTotal];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            Expense *changedExpense = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [[cell textLabel]setText:[NSString stringWithFormat:@"$%@  %@",[changedExpense amount],[changedExpense itemName]]];
            [[cell detailTextLabel] setText:[changedExpense placeName]];
            [self showTotal];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

-(void) controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

//Method: calculates and diplays the total of the expenses recored so far.
-(NSNumber*)calculateTotal: (NSDate*) date forManagedObjectContext: (NSManagedObjectContext*) managedObjectContext {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Expense"];
    
    //query the request as the required date
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@",date];
    [fetchRequest setPredicate:predicate];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:managedObjectContext];
    
    // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"amount"]];
    fetchRequest.returnsDistinctResults = NO;
    
    // Now it should yield an NSArray of distinct values in dictionaries.
    NSArray *dictionaries = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    int sum = 0;
    
    if ([dictionaries count] > 0) {
        
        for(id amt in dictionaries) {
            NSNumber *amount = [amt objectForKey:@"amount"];
            int number = [amount intValue];
            sum += number;
        }
    }
    return [NSNumber numberWithInt:sum];
}

-(void) showTotal {
    AddExpenseViewController *aevc = [[AddExpenseViewController alloc]init];
    [total setText:[NSString stringWithFormat:@"$%@",[self calculateTotal:[aevc getTodaysDate] forManagedObjectContext:[self managedObjectContext]]]];
}


@end
