//
//  SMLagButton.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMLagButton.h"
#import "Masonry.h"

@interface SMLagButton()
@property (nonatomic, strong) UIButton *bt;
@end

@implementation SMLagButton

- (instancetype)initWithStr:(NSString *)str size:(CGFloat)size backgroundColor:(UIColor *)color {
    if (self = [super init]) {
        self.backgroundColor = color;
        self.alpha = 0.7;
        self.layer.cornerRadius = 20;
        self.clipsToBounds = YES;
        UILabel *l = [[UILabel alloc] init];
        l.text = str;
        l.font = [UIFont systemFontOfSize:size];
        l.textColor = [UIColor whiteColor];
        self.bt = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:l];
        [self addSubview:self.bt];
        [l mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [self.bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (RACSignal *)click {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[self.bt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [subscriber sendNext:@"click"];
        }];
        return nil;
    }];
}

@end
