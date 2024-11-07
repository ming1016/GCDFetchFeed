//
//  SMLagButton.h
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface SMLagButton : UIView

- (instancetype)initWithStr:(NSString *)str size:(CGFloat)size backgroundColor:(UIColor *)color;

- (RACSignal *)click;

@end
