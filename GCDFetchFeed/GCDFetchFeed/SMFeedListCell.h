//
//  SMFeedListCell.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMFeedListCellViewModel.h"

@protocol SMFeedListCellDelegate;

@interface SMFeedListCell : UIView

@property (nonatomic, weak) id<SMFeedListCellDelegate> delegate;
- (instancetype)initWithViewModel:(SMFeedListCellViewModel *)viewModel;
- (void)updateWithViewModel:(SMFeedListCellViewModel *)viewModel;

@end

@protocol SMFeedListCellDelegate <NSObject>

@optional
- (void)smFeedListCellView:(SMFeedListCell *)cell clickWithItemModel:(SMFeedItemModel *)itemModel;

@end