//
//  PhotosForPlaceViewController.m
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "PhotosForPlaceViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface PhotosForPlaceViewController ()


@end

@implementation PhotosForPlaceViewController
@synthesize locationToSearch =_locationToSearch;
@synthesize photos=_photos;
@synthesize activityIndi=_activityIndi;
@synthesize barButton =_barButton;
@synthesize thumbnails=_thumbnails;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = [self.locationToSearch valueForKey:@"woe_name"];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.locationToSearch maxResults:PICTURES_PER_CITY];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbnails = [NSMutableArray array];
            for (int i=0; i<[self.photos count]; i++){
                [self.thumbnails addObject:@"empty"];
            }
            
            [self.activityIndi removeFromSuperview];
        });
    });
    
}

-(void) setPhotos:(NSArray *)photos{
    if (_photos != photos) {
        _photos = photos;
        //[self updateSplitViewDetail];
        // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }

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
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotosCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *photo = self.photos[indexPath.row];
    NSString *title = [photo objectForKey:@"title"];
    
    NSString *description = [photo valueForKeyPath:@"description._content"];
    if ([title isEqualToString:@""]) {
        title =  [NSMutableString stringWithString: description];
        if ([title isEqualToString:@""]) title=@"Unknown";
    }
    cell.textLabel.text=title;
    cell.detailTextLabel.text=description;
    
    //download preview Images and store them in thumbnails Array
    NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatSquare];
    if ([self.thumbnails[indexPath.row] isEqual:@"empty"]) {
        
        dispatch_queue_t imageQueue= dispatch_queue_create("com.company.app.imageQueue", NULL);
            dispatch_async(imageQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *thumbnail = [UIImage imageWithData:data];
                    if (thumbnail) self.thumbnails[indexPath.row]=thumbnail;
                    if (self.tableView) {
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }                    
                });
            });
    }else cell.imageView.image = self.thumbnails[indexPath.row];
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
        NSDictionary *photo = self.photos[indexPath.row];
        detailVC.photo =photo;
        
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PhotoSegue"]){
    
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    
        PhotoDetailViewController *detailViewController = segue.destinationViewController;
        NSDictionary *photo = self.photos[selectedRowIndex.row];
        detailViewController.photo =photo;
        //NSString *id = [photo valueForKey:@"id"];
        
    }else if ([segue.identifier isEqualToString:@"MapSegue"]){
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSDictionary *photo in self.photos){
             [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
        }
        MapViewController *nextVC =segue.destinationViewController;
        nextVC.annotations=annotations;
     }
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
