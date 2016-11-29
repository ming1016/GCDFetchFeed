//
//  STMURLProtocol.m
//  Pods
//
//  Created by daiming on 2016/11/20.
//
//

#import "STMURLProtocol.h"
#import "STMURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "STMURLCacheModel.h"

static NSString *STMURLProtocolHandled = @"STMURLProtocolHandled";

@interface STMURLProtocol()

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *otherInfoPath;

@end

@implementation STMURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    STMURLCacheModel *sModel = [STMURLCacheModel shareInstance];
    
    //User-Agent来过滤
    if (sModel.whiteUserAgent.length > 0) {
        NSString *uAgent = [request.allHTTPHeaderFields objectForKey:@"User-Agent"];
        if (uAgent) {
            if (![uAgent hasSuffix:sModel.whiteUserAgent]) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    //只允许GET方法通过
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return nil;
    }
    //防止递归
    if ([NSURLProtocol propertyForKey:STMURLProtocolHandled inRequest:request]) {
        return NO;
    }
    //对于域名白名单的过滤
    if (sModel.whiteListsHost.count > 0) {
        id isExist = [sModel.whiteListsHost objectForKey:request.URL.host];
        if (!isExist) {
            return nil;
        }
    }
    NSString *scheme = [[request.URL scheme] lowercaseString];
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        //
    } else {
        return NO;
    }
    return YES;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    STMURLCacheModel *sModel = [STMURLCacheModel shareInstance];
    
    self.filePath = [sModel filePathFromRequest:self.request isInfo:NO];
    self.otherInfoPath = [sModel filePathFromRequest:self.request isInfo:YES];
    NSDate *date = [NSDate date];

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL expire = false;
    if ([fm fileExistsAtPath:self.filePath]) {
        //有缓存文件的情况
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:self.otherInfoPath];
        NSInteger createTime = [[otherInfo objectForKey:@"time"] integerValue];
        if (sModel.cacheTime > 0) {
            if (createTime + sModel.cacheTime < [date timeIntervalSince1970]) {
                expire = true;
            }
        }
        if (expire == false) {
            //从缓存里读取数据
            NSData *data = [NSData dataWithContentsOfFile:self.filePath];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:[otherInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
            
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        } else {
            //cache失效了
            [fm removeItemAtPath:self.filePath error:nil];      //清除缓存data
            [fm removeItemAtPath:self.otherInfoPath error:nil]; //清除缓存其它信息
        }
    } else {
        expire = true;
    }
    
    if (expire) {
        NSMutableURLRequest *newRequest = [self.request mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:STMURLProtocolHandled inRequest:newRequest];
        
        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    }
    
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnection Delegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.response = response;
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    //开始缓存
    NSDate *date = [NSDate date];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[date timeIntervalSince1970]],@"time",self.response.MIMEType,@"MIMEType",self.response.textEncodingName,@"textEncodingName", nil];
    [dic writeToFile:self.otherInfoPath atomically:YES];
    [self.data writeToFile:self.filePath atomically:YES];
    
    [self clear];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    [self clear];
}

#pragma mark - Helper
- (void)clear {
    [self setData:nil];
    [self setConnection:nil];
    [self setResponse:nil];
}
- (void)appendData:(NSData *)newData
{
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }
    else {
        [[self data] appendData:newData];
    }
}


@end
