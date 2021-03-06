//
//  FindTableViewController.m
//  Shoestring
//
//  Created by Mark Wigglesworth on 12/09/13.
//  Copyright (c) 2013 mark. All rights reserved.
//

#import "FindTableViewController.h"
#import "CloudService.h"
#import "Categories.h"

@interface FindTableViewController ()

@property (strong, nonatomic) NSArray *recommendations;
@property NSUInteger runningTasks;

@end

@implementation FindTableViewController

@synthesize selectedCat, selectedDistance, userLat, userLong, businessObjectList;



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
    
    //NSLog(@"passedCat %@", selectedCat);
    //NSLog(@"passedDistance %@", selectedDistance);
    //NSLog(@"passeduserLat %@", userLat);
    //NSLog(@"passeduserLong %@", userLong);
    
    [self setTitle:selectedCat];
    
    businessObjectList = [[NSMutableArray alloc]init];
    
    //we need a Loading message
    HUD = [[MBProgressHUD alloc] initWithView: [self view]];
    [[self view] addSubview:HUD];
    [HUD setDelegate:self];
    [HUD setLabelText:@"Loading..."];
    self.runningTasks = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL findRecommendations = [defaults boolForKey:@"findRecommendations"];
    BOOL findYelp = [defaults boolForKey:@"findYelp"];
    
    
    if (findYelp) [self testGETRequest];
    
    if (findRecommendations)
    {
        // Load recommendations
        self.recommendations = nil;
        CloudService *cloudService = [CloudService getInstance];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:userLat longitude:userLong];
        
        ++self.runningTasks;
        [HUD show:YES];
        [cloudService getRecommendationsFor:location category:[Categories getIndexFor:selectedCat] maxDistance:[NSNumber numberWithFloat:selectedDistance/1609.0f] completion:^(NSArray *result, NSError *error)
         {
             if(--self.runningTasks == 0) [HUD hide:YES];
             if (!error && result.count > 0)
             {
                 //NSLog(@"Recommendations: %@", result);
                 self.recommendations = result;
                 [self.tableView reloadData];
             }
         }];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"cellToMapSegue"]) {
        
        // Get destination view
        FindMapViewController *findMapVC = [segue destinationViewController];
        
        // perpare passing data
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NSString *passedName, *passedSubtitle, *passedAddress;
        
        if (self.recommendations && path.section == 0)
        {
            passedName = [self.recommendations[path.row] objectForKey:@"name"];
            passedSubtitle = [self.recommendations[path.row] objectForKey:@"comment"];
            findMapVC.lat = [self.recommendations[path.row] objectForKey:@"latitude"];
            findMapVC.lon = [self.recommendations[path.row] objectForKey:@"longitude"];
            findMapVC.haveLatLon = YES;
        }
        else
        {
            passedName = [[businessObjectList objectAtIndex:path.row] objectForKey:@"name"];
            passedAddress = [[businessObjectList objectAtIndex:path.row] objectForKey:@"address"];
            passedSubtitle = [NSString stringWithFormat:@"Rating from Yelp: %@\n Phone:%@", [[businessObjectList objectAtIndex:path.row] objectForKey:@"rating"], [[businessObjectList objectAtIndex:path.row] objectForKey:@"phone"]];
            findMapVC.haveLatLon = NO;
        }
               
        //passing data here
        [findMapVC setAddressFromFT:passedAddress];
        [findMapVC setNameFromFT:passedName];
        [findMapVC setSubtitleFromFT:passedSubtitle];
        [findMapVC setCategory: selectedCat];
        
       
        //NSLog(@"nameFromFT %@", passedName);
        //NSLog(@"addressFromFT %@", passedAddress);
        //NSLog(@"phoneFromFT %@", passedPhone);
        //NSLog(@"ratingFromFT %@", passedRating);
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (self.recommendations && businessObjectList.count > 0) return 2;
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.recommendations && businessObjectList.count > 0)
    {
        if (section == 0)
            return @"Recommendations";
        else
            return @"Other Places";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.recommendations && section == 0)
        return self.recommendations.count;
    return [businessObjectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.recommendations && indexPath.section == 0)
    {
        cell.textLabel.text =  [self.recommendations[indexPath.row] objectForKey:@"name"];
        NSString *stars;
        switch ([[self.recommendations[indexPath.row] objectForKey:@"rating"] integerValue])
        {
            case 1: stars = @"★☆☆☆☆ "; break;
            case 2: stars = @"★★☆☆☆ "; break;
            case 3: stars = @"★★★☆☆ "; break;
            case 4: stars = @"★★★★☆ "; break;
            case 5: stars = @"★★★★★ "; break;
            default: stars = @""; break;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ \"%@\"", stars, [self.recommendations[indexPath.row] objectForKey:@"comment"]];
        cell.imageView.image = [UIImage imageNamed:@"recommendation.png"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else
    {
        cell.textLabel.text = [[businessObjectList objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [[businessObjectList objectAtIndex:indexPath.row] objectForKey:@"address"];
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[businessObjectList objectAtIndex:indexPath.row] objectForKey:@"imageurl"]]]];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"cellToMapSegue" sender:self];
}

#pragma mark - Yelp API methods

//Method to get the request fromn the API
- (void)testGETRequest
{
    
    //show the loading icon
    [HUD show:YES];
    ++self.runningTasks;
    
    
    //create the url for the request (with params)
    NSString *term = selectedCat;
    if([term isEqual: @"Travel"])
    {
        term = @"transport";
    }
    NSString *latLon = [NSString stringWithFormat:@"%@,%@", [NSString stringWithFormat:@"%.8f", userLat], [NSString stringWithFormat:@"%.8f", userLong]];
    NSString *radius = [NSString stringWithFormat:@"%u", selectedDistance];
    NSString *urlString = [NSString stringWithFormat:
                           @"http://api.yelp.com/v2/search?%@=%@&%@=%@&%@=%@",
                           @"term",term, @"ll",latLon, @"radius_filter", radius];
    
    //NSLog(@"url: %@", urlString);
    
    
    
    NSString *escapedURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *URL = [NSURL URLWithString:escapedURL];
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET];
    OAToken *token = [[OAToken alloc] initWithKey:ACCESS_TOKEN secret:ACCESS_TOKEN_SECRET];
    
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    _responseData = [[NSMutableData alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               //call the json parsing method to serialise the data
                               NSDictionary *parsedData = [self parseJson: data];
                               //result form parsedData, pull this to arrays.
                               
                               NSArray *businesses = parsedData[@"businesses"];
                               //NSLog(@"businesses: %@", businesses);
                               
                               
                               
                               //NSMutableArray *tempArray = [NSMutableArray new];
                               
                               NSString *name = @"";
                               NSString *address = @"";
                               NSString *imageURL = @"";
                               NSString *phoneNo =@"";
                               NSString *rating =@"";
                               
                               for (id business in businesses) {
                                   NSMutableDictionary *businessInfo = [NSMutableDictionary dictionary];
                                   //name
                                   name = business[@"name"];
                                   //NSLog(@"name: %@", name);
                                   
                                   //imageurl
                                   imageURL = business[@"image_url"];
                                   if(imageURL.length == 0){
                                       imageURL = @"no photo";
                                   }
                                   //NSLog(@"url: %@", imageURL);
                                  
                                   //phone
                                   phoneNo = business[@"display_phone"];
                                   if(phoneNo.length == 0){
                                       phoneNo = @"phone number not display";
                                   }
                                   //NSLog(@"phone no: %@", phoneNo);
                                   
                                   //rating
                                   rating = business[@"rating"];
                                   //NSLog(@"rating: %@", rating);

                                   
                                   //address
                                   NSArray *tempAddress = business[@"location"][@"display_address"];
                                   NSUInteger index;
                                   
                                   address = @"";
                                   
                                   for (id addr in tempAddress){
                                       index = [tempAddress indexOfObject:addr];
                                       
                                       if(index < [tempAddress count]-1){
                                           address = [address stringByAppendingString:addr];
                                           address = [address stringByAppendingString:@","];
                                       }else{
                                           address = [address stringByAppendingString:addr];
                                       }
                                   }
                                   //NSLog(@"address: %@", address);
                                   
                                   //Add to dictionary
                                   [businessInfo setObject:name forKey:@"name"];
                                   //NSLog(@"dic name: %@ \n", [businessInfo objectForKey:@"name"]);
                                   [businessInfo setObject:imageURL forKey:@"imageurl"];
                                   //NSLog(@"dic url: %@ \n", [businessInfo objectForKey:@"imageurl"]);
                                   [businessInfo setObject:phoneNo forKey:@"phone"];
                                   //NSLog(@"phone: %@ \n", [businessInfo objectForKey:@"display_phone"]);
                                   [businessInfo setObject:rating forKey:@"rating"];
                                   //NSLog(@"rating: %@ \n", [businessInfo objectForKey:@"rating"]);
                                   [businessInfo setObject:address forKey:@"address"];
                                   //NSLog(@"dic address: %@ \n", [businessInfo objectForKey:@"address"]);
                                   
                                   //Add to ObjectList
                                   //NSLog(@"business list:%@",businessInfo);
                                   [businessObjectList addObject:businessInfo];
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //NSLog(@"business list:%@",businessObjectList);
                                   [self.tableView reloadData];
                                   if(--self.runningTasks == 0) [HUD hide:YES];
                               });
                               
                           }];
}

//Method to parse the json
- (NSDictionary*)parseJson:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          options:kNilOptions
                          error:&error];
    
    return json;
}


#pragma mark -
#pragma mark - Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Error");
}




@end
