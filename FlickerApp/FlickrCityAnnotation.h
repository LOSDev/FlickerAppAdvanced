//
//  FlickrCityAnnotation.h
//  FlickerApp
//
//  Created by Rincewind on 20.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrCityAnnotation : NSObject <MKAnnotation>

+ (FlickrCityAnnotation *)annotationForCity:(NSDictionary *)city; // Flickr city dictionary

@property (nonatomic, strong) NSDictionary *city;

@end
