//
//  SMStackCell.h
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMCallStackModel.h"

@interface SMStackCell : UITableViewCell

- (void)updateWithModel:(SMCallStackModel *)model;

@end
