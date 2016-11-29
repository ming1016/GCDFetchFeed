//
//  STMURLCacheModel.h
//  HomePageTest
//
//  Created by daiming on 2016/11/14.
//

#import <Foundation/Foundation.h>

@interface STMURLCacheModel : NSObject

//-----------属性--------------
@property (nonatomic, assign) NSUInteger memoryCapacity;
@property (nonatomic, assign) NSUInteger diskCapacity;
@property (nonatomic, assign) NSUInteger cacheTime;
@property (nonatomic, copy) NSString *subDirectory;

@property (nonatomic) BOOL isDownloadMode; //是否为下载模式
@property (nonatomic) BOOL isSavedOnDisk;  //是否存磁盘

@property (nonatomic, copy) NSString *diskPath;   //磁盘路径
@property (nonatomic, strong) NSMutableDictionary *responseDic; //防止下载请求的循环调用

@property (nonatomic, copy) NSString *cacheFolder;

@property (nonatomic, strong) NSMutableDictionary *whiteListsHost;       //域名白名单
@property (nonatomic, strong) NSMutableDictionary *whiteListsRequestUrl; //请求地址白名单
@property (nonatomic, strong) NSString *whiteUserAgent;             //WebView的user-agent白名单

@property (nonatomic, strong) NSString *replaceUrl;
@property (nonatomic, strong) NSData *replaceData;

//NSURLProtocol
@property (nonatomic) BOOL isUsingURLProtocol; //是否使用URLProtocol

//----------方法---------------
//查找请求对应的文件路径
- (NSString *)filePathFromRequest:(NSURLRequest *)request isInfo:(BOOL)info;
//清除请求对应的缓存
- (void)removeCacheFileWithRequest:(NSURLRequest *)request;
//根据请求进行判断localResourcePathDic是否已经缓存，有返回NSCachedURLResponse,没有的话返回nil
- (NSCachedURLResponse *)localCacheResponeWithRequest:(NSURLRequest *)request;
//清除缓存
- (void)checkCapacity;

//for NSURLProtocol
+ (STMURLCacheModel *)shareInstance;

+ (NSString *)md5Hash:(NSString *)str;

@end
