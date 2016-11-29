//  Created by daiming on 2016/11/11.

#import "STMURLCacheMk.h"

@interface STMURLCacheMk()

@end

@implementation STMURLCacheMk

- (instancetype)init {
    if (self = [super init]) {
        self.cModel = [[STMURLCacheModel alloc] init];
    }
    return self;
}
- (STMURLCacheMk *(^)(NSString *)) whiteUserAgent {
    return ^STMURLCacheMk *(NSString *v) {
        self.cModel.whiteUserAgent = v;
        UIWebView *wb = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *defaultAgent = [wb stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *agentForWhite = [defaultAgent stringByAppendingString:v];
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:agentForWhite, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
        return self;
    };
}
- (STMURLCacheMk *(^)(NSString *))addRequestUrlWhiteList {
    return ^STMURLCacheMk *(NSString *v) {
        [self.cModel.whiteListsRequestUrl setObject:[NSNumber numberWithBool:TRUE] forKey:v];
        return self;
    };
}

- (STMURLCacheMk *(^)(NSString *))addHostWhiteList {
    return ^STMURLCacheMk *(NSString *v) {
        [self.cModel.whiteListsHost setObject:[NSNumber numberWithBool:TRUE] forKey:v];
        return self;
    };
}
- (STMURLCacheMk *(^)(NSUInteger))memoryCapacity {
    return ^STMURLCacheMk *(NSUInteger v) {
        self.cModel.memoryCapacity = v;
        return self;
    };
}
- (STMURLCacheMk *(^)(NSUInteger))diskCapacity {
    return ^STMURLCacheMk *(NSUInteger v) {
        self.cModel.diskCapacity = v;
        return self;
    };
}

- (STMURLCacheMk *(^)(NSUInteger))cacheTime {
    return ^STMURLCacheMk *(NSUInteger v) {
        self.cModel.cacheTime = v;
        return self;
    };
}
- (STMURLCacheMk *(^)(NSString *))subDirectory {
    return ^STMURLCacheMk *(NSString *v) {
        self.cModel.subDirectory = v;
        return self;
    };
}
- (STMURLCacheMk *(^)(NSArray *))whiteListsHost {
    return ^STMURLCacheMk *(NSArray *v) {
        if (v.count > 0) {
            for (NSString *aV in v) {
                [self.cModel.whiteListsHost setObject:[NSNumber numberWithBool:YES] forKey:aV];
            }
        }
        return self;
    };
}
- (STMURLCacheMk *(^)(BOOL)) isDownloadMode {
    return ^STMURLCacheMk *(BOOL v) {
        self.cModel.isDownloadMode = v;
        return self;
    };
}
- (STMURLCacheMk *(^)(BOOL)) isUsingURLProtocol {
    return ^STMURLCacheMk *(BOOL v) {
        self.cModel.isUsingURLProtocol = v;
        return self;
    };
}
//替换请求
- (STMURLCacheMk *(^)(NSString *)) replaceUrl {
    return ^STMURLCacheMk *(NSString *v) {
        self.cModel.replaceUrl = v;
        return self;
    };
}
- (STMURLCacheMk *(^)(NSData *)) replaceData {
    return ^STMURLCacheMk *(NSData *v) {
        self.cModel.replaceData = v;
        return self;
    };
}

@end
