//
//  ArtWork.m
//  GCDFetchFeed
//
//  Created by didi on 16/9/13.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "ArtWork.h"

@implementation ArtWork

- (instancetype)init:(NSString *)title locationName:(NSString *)locationName discipline:(NSString *)discipline coordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.title = title;
        self.locationName = locationName;
        self.discipline = discipline;
        self.coordinate = coordinate;
    }
    return self;
}


@end
