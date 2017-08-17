//
//  SMClsCallCell.h
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/14.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMCallTraceTimeCostModel.h"

@interface SMClsCallCell : UITableViewCell

- (void)updateWithModel:(SMCallTraceTimeCostModel *)model;

@end
