//
//  SMStackCell.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMStackCell.h"
#import "Masonry.h"

@interface SMStackCell()

@property (nonatomic, strong) UILabel *contentLb;

@end

@implementation SMStackCell

- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.contentLb];
    [self.contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(10);
        make.right.bottom.equalTo(self).offset(-10);
    }];
}

- (void)updateWithStr:(NSString *)str {
    self.contentLb.text = str;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentLb.preferredMaxLayoutWidth = self.contentLb.frame.size.width;
}

#pragma mark - Getter
- (UILabel *)contentLb {
    if (!_contentLb) {
        _contentLb = [[UILabel alloc] init];
        _contentLb.numberOfLines = 0;
        _contentLb.font = [UIFont systemFontOfSize:14];
        _contentLb.textColor = [UIColor grayColor];
    }
    return _contentLb;
}

@end
