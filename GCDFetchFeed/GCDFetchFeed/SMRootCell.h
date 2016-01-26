//
//  SMRootCell.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMRootCellViewModel.h"

@protocol SMRootCellDelegate;

@interface SMRootCell : UIView

@property (nonatomic, weak) id<SMRootCellDelegate> delegate;
- (instancetype)initWithViewModel:(SMRootCellViewModel *)viewModel;
- (void)updateWithViewModel:(SMRootCellViewModel *)viewModel;

@end

@protocol SMRootCellDelegate <NSObject>

@optional
- (void)smRootCellView:(SMRootCell *)cell clickWithFeedModel:(SMFeedModel *)feedModel;

@end


