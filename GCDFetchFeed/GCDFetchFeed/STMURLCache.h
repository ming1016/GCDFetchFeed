//  Created by daiming on 2016/11/11.
/*
 功能：缓存网络请求
 */

#import <Foundation/Foundation.h>
#import "STMURLCacheMk.h"

@class ViewController;

@protocol STMURLCacheDelegate;

@interface STMURLCache : NSURLCache

@property (nonatomic, strong) STMURLCacheMk *mk;
@property (nonatomic, weak) id<STMURLCacheDelegate> delegate;
@property (nonatomic, weak) ViewController *actionVC;

+ (STMURLCache *)create:(void(^)(STMURLCacheMk *mk))mk;  //初始化并开启缓存
- (STMURLCache *)update:(void (^)(STMURLCacheMk *mk))mk;

- (STMURLCache *)preLoadByWebViewWithUrls:(NSArray *)urls; //使用WebView进行预加载缓存
- (STMURLCache *)preloadByWebViewWithHtmls:(NSArray *)htmls; //使用以html内容在WebView里读取进行内容预加载缓存
- (STMURLCache *)preLoadByRequestWithUrls:(NSArray *)urls; //使用url

- (void)stop; //关闭缓存

@end

@protocol STMURLCacheDelegate <NSObject>

@optional
- (void)preloadDidStartLoad;
- (void)preloadDidFinishLoad:(UIWebView *)webView remain:(NSUInteger)remain;
- (void)preloadDidFailLoad;
- (void)preloadDidAllDone;

@end
