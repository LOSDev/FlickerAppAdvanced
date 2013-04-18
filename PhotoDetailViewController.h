//
//  PhotoDetailViewController.h
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
@interface PhotoDetailViewController : UIViewController <SplitViewBarButtonItemPresenter, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewWithImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSDictionary *photo;
@property (weak, nonatomic) IBOutlet UIView *barButtonView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndi;

-(void) showImageFromCache:(NSData*) pic;
@end
