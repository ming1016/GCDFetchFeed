//
//  SMImageView.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMImageViewDelegate;

@interface SMImageView : UIView

@property (nonatomic, weak) id<SMImageViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;

//初始化
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImageView:(UIImageView *)imageView;
- (instancetype)initWithImageWebUrl:(NSString *)webUrl;
- (instancetype)initWithImageWebUrl:(NSString *)webUrl placeholderImage:(UIImage *)placeholderImage;

//更新
- (void)updateWithImage:(UIImage *)image;
- (void)updateWithImageView:(UIImageView *)imageView;
- (void)updateWithImageWebUrl:(NSString *)webUrl;
- (void)updateWithImageWebUrl:(NSString *)webUrl placeholderImage:(UIImage *)placeholderImage;

@end

@protocol SMImageViewDelegate <NSObject>

@optional
- (void)whenImageViewClicked:(SMImageView *)imageView;

@end


