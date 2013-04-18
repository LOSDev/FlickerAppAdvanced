//
//  FlickrCityAnnotation.m
//  FlickerApp
//
//  Created by Rincewind on 20.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import "FlickrCityAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrCityAnnotation

@synthesize city = _city;

+ (FlickrCityAnnotation *)annotationForCity:(NSDictionary *)city
{
    FlickrCityAnnotation *annotation = [[FlickrCityAnnotation alloc] init];
    annotation.city = city;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return [self.city objectForKey:@"woe_name"];
}



- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.city objectForKey:@"latitude"] doubleValue];
    coordinate.longitude = [[self.city objectForKey:@"longitude"] doubleValue];
    return coordinate;
}


@end
