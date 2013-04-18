//
//  TopPlacesViewController.h
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoDetailViewController.h"
@interface TopPlacesViewController : UITableViewController <UISplitViewControllerDelegate>
{
    PhotoDetailViewController *detailVC;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndi;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;
    @end
