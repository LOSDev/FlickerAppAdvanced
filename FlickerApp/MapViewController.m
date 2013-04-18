//
//  MapViewController.m
//  FlickerApp
//
//  Created by Rincewind on 20.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "MapViewController.h" 
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"
#import "PhotoDetailViewController.h"
#import "FlickrCityAnnotation.h"
#import "PhotosForPlaceViewController.h"
#import "TopPlacesViewController.h"


@interface MapViewController () <MKMapViewDelegate>

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations =_annotations;
@synthesize segControl;

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}


- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        // could put a rightCalloutAccessoryView here
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = infoButton;
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    
    
    if ([aView.annotation isKindOfClass:[FlickrPhotoAnnotation class]]) {
        FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)aView.annotation;
        NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
                
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *temp = [NSData dataWithContentsOfURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{                
                UIImage *img =[UIImage imageWithData:temp];
                [(UIImageView *)aView.leftCalloutAccessoryView setImage:img];
            });
        });
    }

    
    
    

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[PhotoDetailViewController class]]) {
        
         if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]]) {
             FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)view.annotation;
             NSDictionary *photo = fpa.photo;
             detailVC = (PhotoDetailViewController *) detailVC;
             [detailVC setPhoto:photo];
         }else{
             FlickrCityAnnotation *fca = (FlickrCityAnnotation *)view.annotation;
             NSDictionary *city = fca.city;             
             [self performSegueWithIdentifier:@"LocationSegue2" sender:city];
             
         }
    
    }else{
        if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]]) {
            FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)view.annotation;
            NSDictionary *photo = fpa.photo;
            [self performSegueWithIdentifier:@"PhotoDetailSegue2" sender:photo];
        }else{
            FlickrCityAnnotation *fca = (FlickrCityAnnotation *)view.annotation;
            NSDictionary *city = fca.city;
            [self performSegueWithIdentifier:@"LocationSegue2" sender:city];
            
        }

    
    
    
    
    }
    
}





#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    //NSLog(@"%@",self.annotations);
    self.title=@"Map";
    
     //set the default region and zoom of the MapView
    if ([self.annotations count] == PICTURES_PER_CITY){
        //Zooming in for the City View
        FlickrCityAnnotation *fca = self.annotations[0];
        CLLocationCoordinate2D zoomLocation = [fca coordinate];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, ZOOM_FOR_CITY, ZOOM_FOR_CITY);
        [_mapView setRegion:viewRegion animated:YES];
    }else{
        //World Wide View for all Locations
        FlickrPhotoAnnotation *fpa = self.annotations[0];
        CLLocationCoordinate2D zoomLocation = [fpa coordinate];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, ZOOM_FOR_WORLD, ZOOM_FOR_WORLD);
        [_mapView setRegion:viewRegion animated:YES];
    }
    // 3
    
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"LocationSegue2"]){
        PhotosForPlaceViewController *detailViewController = segue.destinationViewController;
        detailViewController.locationToSearch=(NSDictionary *)sender;
        
    }else if ([segue.identifier isEqualToString:@"PhotoDetailSegue2"]){
        
        PhotoDetailViewController *dest =segue.destinationViewController;
        dest.photo=sender;
    }
}



- (IBAction)segmentChange:(id)sender {
    switch (self.segControl.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
        
    
}
@end
