//
//  PhotoDetailViewController.m
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"
@interface PhotoDetailViewController () 

@end

@implementation PhotoDetailViewController

@synthesize scrollViewWithImage;
@synthesize imageView=_imageView;
@synthesize imageURL = _imageURL;
@synthesize toolBar=_toolBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photo = _photo;
@synthesize titleLabel =_titleLabel;
@synthesize activityIndi;
@synthesize barButtonView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

-(void) updatePreferences:(NSDictionary *) photo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *lastPics= [[prefs objectForKey:@"lastPics"] mutableCopy];
    if(!lastPics) lastPics = [NSMutableArray array];
    if (![lastPics containsObject:photo]) {
        [lastPics insertObject:photo atIndex:0];
    }
    
    if ([lastPics count]>20) [lastPics removeLastObject];
    [prefs setObject:lastPics forKey:@"lastPics"];
    [prefs synchronize];
    
}

-(void)setPhoto:(NSDictionary *)photo{
    _photo=photo;
    self.scrollViewWithImage.zoomScale=1;
    [self.toolBar addSubview:activityIndi];
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndi];
    [self.navigationItem setRightBarButtonItem:barButton];
    [self.activityIndi startAnimating];
    [self updatePreferences:photo];
    [self updateImage];
    
}



-(void) updateImage{
    if (self.photo) {
        
        
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *storePathPicture = [applicationDocumentsDir stringByAppendingPathComponent:@"photo.jpg"];
        NSString *storePathDictionary = [applicationDocumentsDir stringByAppendingPathComponent:@"dictionary.txt"];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:storePathDictionary] &&
            [[NSDictionary dictionaryWithContentsOfFile:storePathDictionary] isEqualToDictionary:self.photo]){
                NSData *picture = [NSData dataWithContentsOfFile:storePathPicture];
                [self showImageFromCache:picture];
                //NSLog(@"cached");
        }else{
            
            //NSLog(@"loaded from Net");
            self.imageURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:self.imageURL];
                [data writeToFile:storePathPicture atomically:NO];
                [self.photo writeToFile:storePathDictionary atomically:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showImageFromCache:data];
                });
            });
            
        }
    }
}


-(void) showImageFromCache:(NSData*) pic{
    
    UIImage *image = [UIImage imageWithData:pic];
    self.imageView.image = image;
    [self.activityIndi stopAnimating];
    [self.navigationItem setRightBarButtonItem:nil];
    
    NSString *title = [self.photo objectForKey:@"title"];
    
    NSString *description = [self.photo valueForKeyPath:@"description._content"];
    if ([title isEqualToString:@""]) {
        title =  [NSMutableString stringWithString: description];
        if ([title isEqualToString:@""]) title=@"Unknown";
    }
    self.titleLabel.text=title;
    
    self.scrollViewWithImage.delegate = self;
    
    self.scrollViewWithImage.contentSize = self.imageView.image.size;
    self.imageView.frame =
    CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndi stopAnimating];
    [self updateImage];
    
	
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



@end
