//
//  SMRootCellViewModel.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMFeedModel.h"

@interface SMRootCellViewModel : NSObject

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *highlightString;
@property (nonatomic, strong) SMFeedModel *feedModel;

@end
