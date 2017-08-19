//
//  STMURLCacheModel.m
//  HomePageTest
//
//  Created by daiming on 2016/11/14.
//

#import "STMURLCacheModel.h"
#import <CommonCrypto/CommonDigest.h>

@implementation STMURLCacheModel

#pragma mark - For NSURLProtocol
+ (STMURLCacheModel *)shareInstance {
    static STMURLCacheModel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STMURLCacheModel alloc] init];
    });
    return instance;
}

#pragma mark - Interface
- (NSCachedURLResponse *)localCacheResponeWithRequest:(NSURLRequest *)request {
    
    __block NSCachedURLResponse *cachedResponse = nil;
    NSString *filePath = [self filePathFromRequest:request isInfo:NO];
    NSString *otherInfoPath = [self filePathFromRequest:request isInfo:YES];
    NSDate *date = [NSDate date];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        //有缓存文件的情况
        BOOL expire = false;
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
        if (self.cacheTime > 0) {
            NSInteger createTime = [[otherInfo objectForKey:@"time"] integerValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                expire = true;
            }
        }
        if (expire == false) {
            //从缓存里读取数据
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[otherInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            return cachedResponse;
        } else {
            //cache失效了
            [fm removeItemAtPath:filePath error:nil];      //清除缓存data
            [fm removeItemAtPath:otherInfoPath error:nil]; //清除缓存其它信息
            return nil;
        }
    } else {
        //从网络读取
        self.isSavedOnDisk = NO;
        id isExist = [self.responseDic objectForKey:request.URL.absoluteString];
        if (isExist == nil) {
            [self.responseDic setValue:[NSNumber numberWithBool:TRUE] forKey:request.URL.absoluteString];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    cachedResponse = nil;
                } else {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",[date timeIntervalSince1970]],@"time",response.MIMEType,@"MIMEType",response.textEncodingName,@"textEncodingName", nil];
                    BOOL resultO = [dic writeToFile:otherInfoPath atomically:YES];
                    BOOL result = [data writeToFile:filePath atomically:YES];
                    if (resultO == NO || result == NO) {
                    } else {
                    }
                    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                }
            }];
            [task resume];
            return cachedResponse;
        }
        return nil;
    }
}

- (void)removeCacheFileWithRequest:(NSURLRequest *)request {
    NSString *filePath = [self filePathFromRequest:request isInfo:NO];
    NSString *otherInfoFilePath = [self filePathFromRequest:request isInfo:YES];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:filePath error:nil];
    [fm removeItemAtPath:otherInfoFilePath error:nil];
}

#pragma mark - Cache Helper
- (NSString *)filePathFromRequest:(NSURLRequest *)request isInfo:(BOOL)info {
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *fileInfoPath = [self cacheFilePath:otherInfoFileName];
    if (info) {
        return fileInfoPath;
    }
    return filePath;
}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
    return [STMURLCacheModel md5Hash:[NSString stringWithFormat:@"%@",requestUrl]];
}
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
    return [STMURLCacheModel md5Hash:[NSString stringWithFormat:@"%@-otherInfo",requestUrl]];
}
- (NSString *)cacheFilePath:(NSString *)file {
    NSString *path = [NSString stringWithFormat:@"%@/%@",self.diskPath,self.cacheFolder];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        //
    } else {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *subDirPath = [NSString stringWithFormat:@"%@/%@/%@",self.diskPath,self.cacheFolder,self.subDirectory];
    if ([fm fileExistsAtPath:subDirPath isDirectory:&isDir] && isDir) {
        //
    } else {
        [fm createDirectoryAtPath:subDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cFilePath = [NSString stringWithFormat:@"%@/%@",subDirPath,file];
    NSLog(@"%@",cFilePath);
    return cFilePath;
}

//清除自建的缓存目录
- (void)checkCapacity {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([self folderSize] > self.diskCapacity) {
            [self deleteCacheFolder];
        }
    });
}
- (void)deleteCacheFolder {
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFolderPath] error:nil];
}
- (NSUInteger)folderSize {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[self cacheFolderPath] error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self cacheFolderPath] stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDic fileSize];
    }
    return (NSUInteger)fileSize;
}
#pragma mark - Function Helper
+ (NSString *)md5Hash:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString *md5Result = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return md5Result;
}
- (NSString *)cacheFolderPath {
    return [NSString stringWithFormat:@"%@/%@/%@",self.diskPath,self.cacheFolder,self.subDirectory];
}

#pragma mark - Getter
- (NSString *)diskPath {
    if (!_diskPath) {
        _diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
    return _diskPath;
}
- (NSMutableDictionary *)responseDic {
    if (!_responseDic) {
        _responseDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _responseDic;
}
- (NSString *)cacheFolder {
    if (!_cacheFolder) {
        _cacheFolder = @"Url";
    }
    return _cacheFolder;
}
- (NSString *)subDirectory {
    if (!_subDirectory) {
        _subDirectory = @"UrlCacheDownload";
    }
    return _subDirectory;
}
- (NSUInteger)memoryCapacity {
    if (!_memoryCapacity) {
        _memoryCapacity = 20 * 1024 * 1024;
    }
    return _memoryCapacity;
}
- (NSUInteger)diskCapacity {
    if (!_diskCapacity) {
        _diskCapacity = 200 * 1024 * 1024;
    }
    return _diskCapacity;
}
- (NSUInteger)cacheTime {
    if (!_cacheTime) {
        _cacheTime = 0;
    }
    return _cacheTime;
}
- (NSMutableDictionary *)whiteListsHost {
    if (!_whiteListsHost) {
        _whiteListsHost = [NSMutableDictionary dictionary];
    }
    return _whiteListsHost;
}
- (NSMutableDictionary *)whiteListsRequestUrl {
    if (!_whiteListsRequestUrl) {
        _whiteListsRequestUrl = [NSMutableDictionary dictionary];
    }
    return _whiteListsRequestUrl;
}
- (NSString *)whiteUserAgent {
    if (!_whiteUserAgent) {
        _whiteUserAgent = @"";
    }
    return _whiteUserAgent;
}
- (NSString *)replaceUrl {
    if (!_replaceUrl) {
        _replaceUrl = @"";
    }
    return _replaceUrl;
}

@end
