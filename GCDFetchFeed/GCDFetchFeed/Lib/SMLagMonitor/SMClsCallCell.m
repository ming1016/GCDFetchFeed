//
//  SMClsCallCell.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/14.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMClsCallCell.h"
#import "Masonry.h"

@interface SMClsCallCell()

@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *desLb;
@property (nonatomic, strong) UILabel *pathLb;

@end

@implementation SMClsCallCell

- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.nameLb];
    [self addSubview:self.desLb];
    [self addSubview:self.pathLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(10);
    }];
    [self.desLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLb.mas_bottom).offset(10);
        make.left.equalTo(self.nameLb);
    }];
    [self.pathLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.desLb.mas_bottom).offset(10);
        make.left.equalTo(self.nameLb);
        make.right.equalTo(self).offset(-20);
    }];
}

- (void)updateWithModel:(SMCallTraceTimeCostModel *)model {
    self.nameLb.text = [NSString stringWithFormat:@"[%@ %@]",model.className,model.methodName];
    self.desLb.text = [NSString stringWithFormat:@"频次:%lu 深度:%lu 耗时:%f",(unsigned long)model.frequency,(unsigned long)model.callDepth, model.timeCost * 1000];
    self.pathLb.text = model.path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.pathLb.preferredMaxLayoutWidth = self.pathLb.frame.size.width;
}

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.font = [UIFont systemFontOfSize:14];
        _nameLb.textColor = [UIColor grayColor];
    }
    return _nameLb;
}
- (UILabel *)desLb {
    if (!_desLb) {
        _desLb = [[UILabel alloc] init];
        _desLb.font = [UIFont systemFontOfSize:12];
        _desLb.textColor = [UIColor lightGrayColor];
    }
    return _desLb;
}
- (UILabel *)pathLb {
    if (!_pathLb) {
        _pathLb = [[UILabel alloc] init];
        _pathLb.numberOfLines = 0;
        _pathLb.font = [UIFont systemFontOfSize:12];
        _pathLb.textColor = [UIColor lightGrayColor];
    }
    return _pathLb;
}
@end
