//
//  MetricsSubscriber.m
//  GCDFetchFeed
//
//  Created by Ming on 2024/11/8.
//  Copyright © 2024 Starming. All rights reserved.
//

#import "MetricsSubscriber.h"

@implementation MetricsSubscriber

- (instancetype)init {
    self = [super init];
    if (self) {
        [[MXMetricManager sharedManager] addSubscriber:self];
    }
    return self;
}

- (void)didReceiveMetricPayloads:(NSArray<MXMetricPayload *> *)payloads {
    for (MXMetricPayload *payload in payloads) {
        MXAppLaunchMetric *launchMetrics = payload.applicationLaunchMetrics;
        if (launchMetrics) {
            NSLog(@"Launch Time: %@", launchMetrics.histogrammedTimeToFirstDraw);
        }
    }
}

@end
