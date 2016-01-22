//
//  SMRootCell.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMRootCellViewModel.h"


@interface SMRootCell : UIView

- (instancetype)initWithViewModel:(SMRootCellViewModel *)viewModel;

- (void)updateWithViewModel:(SMRootCellViewModel *)viewModel;

@end
