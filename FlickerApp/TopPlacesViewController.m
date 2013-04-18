//
//  TopPlacesViewController.m
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotosForPlaceViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "MapViewController.h"
#import "FlickrCityAnnotation.h"
#import "FlickrPhotoAnnotation.h"


@interface TopPlacesViewController ()

@property (nonatomic) NSMutableDictionary *countryArrays;
@property NSArray *countries;
@end

@implementation TopPlacesViewController

@synthesize countryArrays=_countryArrays;
@synthesize countries=_countries;
@synthesize activityIndi =_activityIndi;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (PhotoDetailViewController *)detailVC
{
	if (!self.detailVC) detailVC = [[PhotoDetailViewController alloc] init];
	return self.detailVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupCountryArrays];
    
    
    self.title=@"Top Places";
    
}
-(void) setupCountryArrays{
    self.countryArrays =[NSMutableDictionary dictionary];
    self.countries =[NSArray array];
    
    //get the data via FlickrFetcher
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
       NSArray *temp = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sortArrays:temp];
            [self.activityIndi removeFromSuperview];
        });
    });
}

-(void)setCountryArrays:(NSMutableDictionary *)countryArrays{
    if (_countryArrays!=countryArrays) {
        _countryArrays=countryArrays;
    }
    if (self.tableView.window) [self.tableView reloadData];
    
    
}

-(void) sortArrays:(NSArray *) temp{
    NSMutableArray *tempCountries = [NSMutableArray array];
    
    for (NSDictionary *obj in temp) {
        NSString *country = [obj valueForKey:@"_content"];
        NSArray* foo = [country componentsSeparatedByString: @", "];
        
        country = [foo lastObject];
        
        if (![tempCountries containsObject:country]) [tempCountries addObject:country];
        
        NSMutableArray *countryArray = [self.countryArrays valueForKey:country];
        if(!countryArray) countryArray = [NSMutableArray array];
        [countryArray addObject:obj];
        
        [self.countryArrays setObject:countryArray forKey:country];
    }
    
    //set and sort the countries Array
    self.countries = [tempCountries sortedArrayUsingSelector:
                      @selector(localizedCaseInsensitiveCompare:)];
    
    //sorting each Array in the Dictionary alphabetically
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in self.countryArrays) {
        NSArray *arr = [self.countryArrays objectForKey:key];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_content" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        arr = [arr sortedArrayUsingDescriptors:sortDescriptors];
        [result setObject:arr forKey:key];
        
    }
    self.countryArrays = result;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.countryArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSString * country = self.countries[section];
    NSArray *cities = [self.countryArrays valueForKey:country];
    return [cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopPlacesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger section = indexPath.section;
    NSString *country = self.countries[section];
    NSArray *cities = [self.countryArrays valueForKey:country];
    NSDictionary *cityDict = cities[indexPath.row];
    
    NSString *city = [cityDict objectForKey:@"woe_name"];
    NSString *location = [cityDict objectForKey:@"_content"];
    cell.textLabel.text=city;
    cell.detailTextLabel.text=location;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.countries[section];
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
    
     
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LocationSegue"]){
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        
        PhotosForPlaceViewController *detailViewController = segue.destinationViewController;
        NSString *country = self.countries[selectedRowIndex.section];
        NSArray *city = [self.countryArrays objectForKey:country];
        NSDictionary *location = city[selectedRowIndex.row];
        detailViewController.locationToSearch=location;
        
    }else  if ([segue.identifier isEqualToString:@"MapSegue"]){
        
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSString *key in self.countryArrays){
            NSArray *country = [self.countryArrays valueForKey:key];
            for (NSDictionary *city in country) {
                [annotations addObject:[FlickrCityAnnotation annotationForCity:city]];
            }
            
        }
        MapViewController *nextVC =segue.destinationViewController;
        nextVC.annotations=annotations;
    }
    
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.splitViewController.delegate = self;

}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailV = [self.splitViewController.viewControllers lastObject];
    if (![detailV conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailV = nil;
    }
    return detailV;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}
-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc{
    
    barButtonItem.title = @"Menu";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
    
    
}







@end
