//
//  LastImagesViewController.m
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "LastImagesViewController.h"
#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"


@interface LastImagesViewController ()
@property NSMutableArray *lastPics;
@property NSMutableArray *thumbnails;
@end

@implementation LastImagesViewController
@synthesize lastPics = _lastPics;
@synthesize thumbnails =_thumbnails;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastPics = [[defaults objectForKey:@"lastPics"] mutableCopy];
    if (!self.lastPics) self.lastPics = [NSMutableArray array];
    self.title=@"Last Images";
    self.thumbnails = [NSMutableArray array];
    for (int i=0; i<[self.lastPics count]; i++){
        [self.thumbnails addObject:@"empty"];
    }
    //NSLog(@"%d",[self.thumbnails count]);

}
- (void)viewDidLoad
{
    [super viewDidLoad];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.lastPics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photo = self.lastPics[indexPath.row];
    NSString *title = [photo objectForKey:@"title"];
    
    NSString *description = [photo valueForKeyPath:@"description._content"];
    if ([title isEqualToString:@""]) {
        title =  [NSMutableString stringWithString: description];
        if ([title isEqualToString:@""]) title=@"Unknown";
    }
    cell.textLabel.text=title;
    cell.detailTextLabel.text=description;
    
    
    NSURL *url = [FlickrFetcher urlForPhoto:self.lastPics[indexPath.row] format:FlickrPhotoFormatSquare];
    if ([self.thumbnails[indexPath.row] isEqual:@"empty"]) {
        //if (self.tableView.dragging == NO && self.tableView.decelerating == NO){
        dispatch_queue_t imageQueue= dispatch_queue_create("com.company.app.imageQueue", NULL);
        dispatch_async(imageQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *thumbnail = [UIImage imageWithData:data];
                if (thumbnail) self.thumbnails[indexPath.row]=thumbnail;
                //cell.imageView.image = thumbnail;
                
                //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                if (self.tableView) {
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                //[self.tableView reloadData];
                
            });
        });
    }else
        cell.imageView.image = self.thumbnails[indexPath.row];
    
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
    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[PhotoDetailViewController class]]) {
        PhotoDetailViewController *detailVC = (PhotoDetailViewController *)detail;
        NSDictionary *photo = self.lastPics[indexPath.row];
        detailVC.photo =photo;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LastPicSegue"]){
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        
        PhotoDetailViewController *detailViewController = segue.destinationViewController;
        NSDictionary *photo = self.lastPics[selectedRowIndex.row];
        detailViewController.photo =photo;
        
    }else  if ([segue.identifier isEqualToString:@"MapSegue"]){
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSDictionary *photo in self.lastPics){
            [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
        }
        MapViewController *nextVC =segue.destinationViewController;
        nextVC.annotations=annotations;
    }
}



- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
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
