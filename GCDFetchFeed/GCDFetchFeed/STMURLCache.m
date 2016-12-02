//  Created by daiming on 2016/11/11. 

#import "STMURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "STMURLProtocol.h"

@interface STMURLCache()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *wbView; //用于预加载的webview
@property (nonatomic, strong) NSMutableArray *preLoadWebUrls; //预加载的webview的url列表
@property (nonatomic) BOOL isUseHtmlPreload;

@end

@implementation STMURLCache
#pragma mark - Interface
+ (STMURLCache *)create:(void (^)(STMURLCacheMk *))mk {
    STMURLCache *c = [[self alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    STMURLCacheMk *cMk = [[STMURLCacheMk alloc] init];
    cMk.isDownloadMode(YES);
    mk(cMk);
    c.mk = cMk;
    c = [c configWithMk];
    return c;
}

- (STMURLCache *)configWithMk {
    
    self.mk.cModel.isSavedOnDisk = YES;
    
    if (self.mk.cModel.isUsingURLProtocol) {
        STMURLCacheModel *sModel = [STMURLCacheModel shareInstance];
        sModel.cacheTime = self.mk.cModel.cacheTime;
        sModel.diskCapacity = self.mk.cModel.diskCapacity;
        sModel.diskPath = self.mk.cModel.diskPath;
        sModel.cacheFolder = self.mk.cModel.cacheFolder;
        sModel.subDirectory = self.mk.cModel.subDirectory;
        sModel.whiteUserAgent = self.mk.cModel.whiteUserAgent;
        sModel.whiteListsHost = self.mk.cModel.whiteListsHost;
        [NSURLProtocol registerClass:[STMURLProtocol class]];
    } else {
        [NSURLCache setSharedURLCache:self];
    }
    return self;
}

- (STMURLCache *)update:(void (^)(STMURLCacheMk *))mk {
    mk(self.mk);
    [self configWithMk];
    return self;
}

- (void)stop {
    
    if (self.mk.cModel.isUsingURLProtocol) {
        [NSURLProtocol unregisterClass:[STMURLProtocol class]];
    } else {
        NSURLCache *c = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:c];
    }
    [self.mk.cModel checkCapacity];
}

#pragma mark - Interface PreLoad by Webview
- (STMURLCache *)preLoadByWebViewWithUrls:(NSArray *)urls {
    if (!(urls.count > 0)) {
        return self;
    }
    self.wbView = [[UIWebView alloc] init];
    self.wbView.delegate = self;
    self.preLoadWebUrls = [NSMutableArray arrayWithArray:urls];
    [self requestWebWithFirstPreUrl];
    return self;
}
- (STMURLCache *)preloadByWebViewWithHtmls:(NSArray *)htmls {
    if (!(htmls.count > 0)) {
        return self;
    }
    self.wbView = [[UIWebView alloc] init];
    self.wbView.delegate = self;
    self.preLoadWebUrls = [NSMutableArray arrayWithArray:htmls];
    self.isUseHtmlPreload = YES;
    [self requestWebWithFirstPreHtml];
    return self;
}
//web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(preloadDidStartLoad)]) {
        [self.delegate preloadDidStartLoad];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self requestWebDone];
    if ([self.delegate respondsToSelector:@selector(preloadDidFinishLoad:remain:)]) {
        [self.delegate preloadDidFinishLoad:webView remain:self.preLoadWebUrls.count];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(preloadDidFailLoad)]) {
        [self.delegate preloadDidFailLoad];
    }
    if(error.code == NSURLErrorCancelled)  {
        if (self.preLoadWebUrls.count > 0) {
            [self.preLoadWebUrls removeObjectAtIndex:0];
            if (self.preLoadWebUrls.count == 0) {
                [self preloadAllDone];
            }
        } else {
            [self preloadAllDone];
        }
        return;
    }
    [self requestWebDone];
}

#pragma mark - WebView Delegate Private Method
- (void)requestWebDone {
    if (self.preLoadWebUrls.count > 0) {
        [self.preLoadWebUrls removeObjectAtIndex:0];
        if (self.isUseHtmlPreload) {
            [self requestWebWithFirstPreHtml];
        } else {
            [self requestWebWithFirstPreUrl];
        }
        if (self.preLoadWebUrls.count == 0) {
            [self preloadAllDone];
        }
    } else {
        [self preloadAllDone];
    }
}
- (void)preloadAllDone {
    self.wbView = nil;
    [self stop];
    if ([self.delegate respondsToSelector:@selector(preloadDidAllDone)]) {
        [self.delegate preloadDidAllDone];
    }
}

- (void)requestWebWithFirstPreUrl {
    NSURLRequest *re = [NSURLRequest requestWithURL:[NSURL URLWithString:self.preLoadWebUrls.firstObject] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [self.wbView loadRequest:re];
}
- (void)requestWebWithFirstPreHtml {
    [self.wbView loadHTMLString:self.preLoadWebUrls.firstObject baseURL:nil];
}

#pragma mark - Interface Preload by Request
- (STMURLCache *)preLoadByRequestWithUrls:(NSArray *)urls {
    NSUInteger i = 1;
    for (NSString *urlString in urls) {
        NSMutableURLRequest *re = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        re.HTTPMethod = @"GET";
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:re completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        }];
        [task resume];
        i++;
    }
    
    return self;
}

#pragma mark - NSURLCache Method
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    STMURLCacheModel *cModel = self.mk.cModel;
    //替换请求的处理
    if (cModel.replaceUrl.length > 0 && cModel.replaceData) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"text/html" expectedContentLength:cModel.replaceData.length textEncodingName:@"utf-8"];
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:cModel.replaceData];
        return cachedResponse;
    }
    
    //对于模式的过滤
    if (!cModel.isDownloadMode) {
        return nil;
    }
    //对于域名白名单的过滤
    if (self.mk.cModel.whiteListsHost.count > 0) {
        id isExist = [self.mk.cModel.whiteListsHost objectForKey:[self hostFromRequest:request]];
        if (!isExist) {
            return nil;
        }
    }
    //只允许GET方法通过
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return nil;
    }
    //User-Agent来过滤
    if (self.mk.cModel.whiteUserAgent.length > 0) {
        NSString *uAgent = [request.allHTTPHeaderFields objectForKey:@"User-Agent"];
        if (uAgent) {
            if (![uAgent hasSuffix:self.mk.cModel.whiteUserAgent]) {
                return nil;
            }
        }
    }
    //开始缓存
    NSCachedURLResponse *cachedResponse =  [cModel localCacheResponeWithRequest:request];
    if (cachedResponse) {
        [self storeCachedResponse:cachedResponse forRequest:request];
        return cachedResponse;
    }
    return nil;
}

#pragma mark - Cache Capacity

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    [super removeCachedResponseForRequest:request];
    [self.mk.cModel removeCacheFileWithRequest:request];
}
- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
}

#pragma mark - Helper
- (NSString *)hostFromRequest:(NSURLRequest *)request {
    return [NSString stringWithFormat:@"%@",request.URL.host];
}

#pragma mark - Life
- (void)dealloc {
    NSURLCache *c = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:c];
}

@end
