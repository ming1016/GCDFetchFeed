//
//  SMImageView.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMImageView.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface SMImageView()

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation SMImageView

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithImage:image];
    }
    return self;
}
- (instancetype)initWithImageView:(UIImageView *)imageView {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithImageView:imageView];
    }
    return self;
}
- (instancetype)initWithImageWebUrl:(NSString *)webUrl {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithImageWebUrl:webUrl];
    }
    return self;
}
- (instancetype)initWithImageWebUrl:(NSString *)webUrl placeholderImage:(UIImage *)placeholderImage {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithImageWebUrl:webUrl placeholderImage:placeholderImage];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.imageView];
    [self addSubview:self.clickButton];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.clickButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Interface
- (void)updateWithImage:(UIImage *)image {
    [self.imageView setImage:image];
}
- (void)updateWithImageView:(UIImageView *)imageView {
    self.imageView = imageView;
}
- (void)updateWithImageWebUrl:(NSString *)webUrl {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:webUrl]];
}
- (void)updateWithImageWebUrl:(NSString *)webUrl placeholderImage:(UIImage *)placeholderImage {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:webUrl] placeholderImage:placeholderImage];
}

#pragma mark - Private
- (void)buttonClicked {
    if ([self.delegate respondsToSelector:@selector(whenImageViewClicked:)]) {
        [self.delegate whenImageViewClicked:self];
    }
}

#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _clickButton;
}

@end




