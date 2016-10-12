//
//  SMMapViewController.m
//  GCDFetchFeed
//
//  Created by daiming on 16/9/13.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMMapViewController.h"
#import <MapKit/MapKit.h>
#import "Masonry.h"
#import "ArtWork.h"

@interface SMMapViewController ()

@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation SMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.view addSubview:self.mapView];
    
    [self centerMapOnLocation];
}

- (void)addAnnotation {
    CLLocationCoordinate2D coordinate = {21.283921, -157.831661};
    ArtWork *artwork = [[ArtWork alloc] init: @"King David Kalakaua"
                                locationName: @"Waikiki Gateway Park"
                                  discipline: @"Sculpture"
                                  coordinate: coordinate];
    [self.mapView addAnnotation:artwork];
}

- (void)centerMapOnLocation {
    //1 设置好纬度和经度
    CLLocationCoordinate2D initialLocation = {21.282778, -157.829444};
    CLLocationDistance regionRadius = 1000;
    
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius * 2, regionRadius * 2);
    [self.mapView setRegion:coordinateRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
