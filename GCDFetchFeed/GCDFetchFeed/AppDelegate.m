//
//  AppDelegate.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/19.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "AppDelegate.h"

#import "SMRootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SMRootViewController *rootVC = [[SMRootViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}



@end
