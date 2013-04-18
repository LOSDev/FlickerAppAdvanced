//
//  MapViewController.h
//  FlickerApp
//
//  Created by Rincewind on 20.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define ZOOM_FOR_CITY 45000
#define ZOOM_FOR_WORLD 15000000

@interface MapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *annotations;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
- (IBAction)segmentChange:(id)sender;
@end
