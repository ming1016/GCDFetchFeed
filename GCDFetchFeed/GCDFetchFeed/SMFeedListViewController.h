//
//  SMFeedListViewController.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMFeedModel;

@interface SMFeedListViewController : UIViewController
- (instancetype)initWithFeedModel:(SMFeedModel *)feedModel;

@end
