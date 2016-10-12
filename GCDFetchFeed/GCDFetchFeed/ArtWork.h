//
//  ArtWork.h
//  GCDFetchFeed
//
//  Created by daiming on 16/9/13.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ArtWork : NSObject<MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSString *discipline;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)init:(NSString *)title
        locationName:(NSString *)locationName
          discipline:(NSString *)discipline
          coordinate:(CLLocationCoordinate2D)coordinate;

@end
