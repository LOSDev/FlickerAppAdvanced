//
//  PhotosForPlaceViewController.h
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosForPlaceViewController : UITableViewController <UISplitViewControllerDelegate>
@property (nonatomic) NSArray *photos;
@property (nonatomic,strong)NSDictionary *locationToSearch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndi;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property NSMutableArray *thumbnails;

@end
