//
//  SMFeedListCellViewModel.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMFeedModel.h"

@interface SMFeedListCellViewModel : NSObject

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, strong) SMFeedItemModel *itemModel;
@property (nonatomic, assign) CGFloat cellHeight;

@end
