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
@property (nonatomic, strong) UILabel *dateLb;
@property (nonatomic, strong) UILabel *infoLb;

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
    [self addSubview:self.dateLb];
    [self addSubview:self.infoLb];
    [self.dateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(10);
    }];
    [self.infoLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dateLb.mas_right).offset(20);
        make.top.equalTo(self.dateLb);
    }];
    [self.contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dateLb).offset(10);
        make.top.equalTo(self.dateLb.mas_bottom).offset(10);
        make.right.bottom.equalTo(self).offset(-10);
    }];
}

- (void)updateWithModel:(SMCallStackModel *)model {
    self.contentLb.text = model.stackStr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.dateString];
    self.dateLb.text = [formatter stringFromDate:date];
    if (model.isStuck) {
        self.infoLb.text = @"卡顿问题";
        self.infoLb.textColor = [UIColor redColor];
    } else {
        self.infoLb.text = @"CPU负载高";
        self.infoLb.textColor = [UIColor orangeColor];
    }
    
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
- (UILabel *)dateLb {
    if (!_dateLb) {
        _dateLb = [[UILabel alloc] init];
        _dateLb.font = [UIFont boldSystemFontOfSize:14];
        _dateLb.textColor = [UIColor grayColor];
    }
    return _dateLb;
}
- (UILabel *)infoLb {
    if (!_infoLb) {
        _infoLb = [[UILabel alloc] init];
        _infoLb.font = [UIFont boldSystemFontOfSize:14];
        _infoLb.textColor = [UIColor redColor];
    }
    return _infoLb;
}

@end
