//
//  STMPartMaker.h
//  HomePageTest
//
//  Created by DaiMing on 16/6/2.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, STMPartAlignment) {
    STMPartAlignmentDefault,
    STMPartAlignmentCenter,
    STMPartAlignmentLeft,
    STMPartAlignmentRight,
    STMPartAlignmentTop,
    STMPartAlignmentBottom
};
typedef NS_ENUM(NSUInteger, STMPartColorType) {
    STMPartColorWhite,
    STMPartColorBlack,
    STMpartColorGray,
    STMpartColorLightGray,
    STMpartColorDarkGray,
    STMpartColorOrange,
    STMpartColorRed
};
//权重
typedef NS_ENUM(NSUInteger, STMPartPriority) {
    STMPriorityDefault,          //不设置，按照默认来
    STMPriorityFittingSizeLevel, //50
    STMPriorityDefaultLow,       //250
    STMPriorityDefaultHigh,      //750
    STMPriorityRequired,         //1000
};

@interface STMPartMaker : NSObject

//----------------属性----------------
//布局
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat padding;
@property (nonatomic, strong) UIView *view;
@property (nonatomic) BOOL isFill;                      //如果设置填充，对应的宽高需要设置为0

@property (nonatomic) STMPartAlignment partAlignment;   //不设置就按照assembleView的设置来
@property (nonatomic) CGFloat alignmentMargin;          //对齐方向和assembleView的间距
@property (nonatomic) STMPartAlignment ignoreAlignment; //需要忽略的约束方向
@property (nonatomic) STMPartPriority CRpriority;      //CompressionResistancePriority

@property (nonatomic) CGFloat minWidth; //最小宽
@property (nonatomic) CGFloat maxWidth; //最大宽

//控件属性
//通用部分
//底部
@property (nonatomic, strong) UIColor *backColor;        //底部设置的颜色
@property (nonatomic, strong) UIColor *backBorderColor;  //边线的颜色
@property (nonatomic) CGFloat backBorderWidth;            //边线的大小
@property (nonatomic) CGFloat backBorderRadius;          //边线半径
@property (nonatomic) CGFloat backPaddingHorizontal;     //左右的间隔
@property (nonatomic) CGFloat backPaddingVertical;       //上下的间隔
@property (nonatomic, strong) UIImage *backImage;        //待实现
//按钮
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIColor *buttonHighlightColor;

//Label
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

//ImageView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *imagePlaceholder;

//----------------方法--------------
//布局
- (STMPartMaker *(^)(UIView *))customViewEqualTo;
- (STMPartMaker *(^)(CGSize))sizeEqualTo;
- (STMPartMaker *(^)(BOOL))isFillEqualTo;
- (STMPartMaker *(^)(CGFloat))paddingEqualTo;
- (STMPartMaker *(^)(STMPartAlignment))partAlignmentEqualTo;
- (STMPartMaker *(^)(CGFloat))alignmentMarginEqualTo;
- (STMPartMaker *(^)(STMPartAlignment))ignoreAlignmentEqualTo;
- (STMPartMaker *(^)(STMPartPriority))CRpriorityEqualTo;
- (STMPartMaker *(^)(CGFloat))minWidthEqualTo;
- (STMPartMaker *(^)(CGFloat))maxWidthEqualTo;

//控件属性
//通用
- (STMPartMaker *(^)(UIColor *))backColorIs;
- (STMPartMaker *(^)(NSString *))backColorHexStringIs;
- (STMPartMaker *(^)(UIColor *))backBorderColorIs;
- (STMPartMaker *(^)(NSString *))backBorderColorHexStringIs;
- (STMPartMaker *(^)(CGFloat))backBorderWidthIs;
- (STMPartMaker *(^)(CGFloat))backBorderRadiusIs;
- (STMPartMaker *(^)(CGFloat))backPaddingHorizontalIs;
- (STMPartMaker *(^)(CGFloat))backPaddingVerticalIs;
- (STMPartMaker *(^)(UIButton *))buttonIs;
- (STMPartMaker *(^)(UIColor *))buttonHighlightColorIs;

//Label
- (STMPartMaker *(^)(NSString *))textIs;
- (STMPartMaker *(^)(UIFont *))fontIs;
- (STMPartMaker *(^)(CGFloat))fontSizeIs;
- (STMPartMaker *(^)(UIColor *))colorIs;
- (STMPartMaker *(^)(NSString *))colorHexStringIs; //十六进制颜色
- (STMPartMaker *(^)(STMPartColorType))colorTypeIs;//颜色类型

//ImageView
- (STMPartMaker *(^)(UIImage *))imageIs;
- (STMPartMaker *(^)(NSString *))imageNameIs;
- (STMPartMaker *(^)(NSString *))imageUrlIs;
- (STMPartMaker *(^)(UIImage *))imagePlaceholderIs;
- (STMPartMaker *(^)(NSString *))imagePlaceholderNameIs;

/*-----辅助方法-----*/
+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end
