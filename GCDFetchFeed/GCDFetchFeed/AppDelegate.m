//
//  AppDelegate.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/19.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "AppDelegate.h"

#import "SMRootViewController.h"
#import "SMFeedListViewController.h"
#import "SMStyle.h"
#import "SMFeedModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SMRootViewController *rootVC = [[SMRootViewController alloc] init];
    UINavigationController *homeNav = [self styleNavigationControllerWithRootController:rootVC];
    UITabBarItem *homeTab = [[UITabBarItem alloc] initWithTitle:@"频道" image:nil tag:1];
    homeTab.titlePositionAdjustment = UIOffsetMake(0, -20);
    homeNav.tabBarItem = homeTab;
    
    SMFeedModel *feedModel = [SMFeedModel new];
    feedModel.fid = 0;
    SMFeedListViewController *feedListVC = [[SMFeedListViewController alloc] initWithFeedModel:feedModel];
    UINavigationController *listNav = [self styleNavigationControllerWithRootController:feedListVC];
    UITabBarItem *listTab = [[UITabBarItem alloc] initWithTitle:@"列表" image:nil tag:2];
    listTab.titlePositionAdjustment = UIOffsetMake(0, -18);
    listNav.tabBarItem = listTab;
    
    UITabBarController *tabBarC = [[UITabBarController alloc]initWithNibName:nil bundle:nil];
    tabBarC.tabBar.tintColor = [SMStyle colorPaperBlack];
    tabBarC.tabBar.barTintColor = [SMStyle colorPaperDark];
    UIView *shaowLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tabBarC.tabBar.frame), 0.5)];
    shaowLine.backgroundColor = [UIColor colorWithHexString:@"D8D7D3"];
    [tabBarC.tabBar addSubview:shaowLine];
    tabBarC.tabBar.shadowImage = [UIImage new];
    tabBarC.tabBar.clipsToBounds = YES;
    tabBarC.viewControllers = @[homeNav,listNav];
    
    self.window.rootViewController = tabBarC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (UINavigationController *)styleNavigationControllerWithRootController:(UIViewController *)vc {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.tintColor = [SMStyle colorPaperBlack];
    nav.navigationBar.barTintColor = [SMStyle colorPaperDark];
    UIView *shaowLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(nav.navigationBar.frame), CGRectGetWidth(nav.navigationBar.frame), 0.5)];
    shaowLine.backgroundColor = [UIColor colorWithHexString:@"D8D7D3"];
    [nav.navigationBar addSubview:shaowLine];
    nav.navigationBar.translucent = NO;
    return nav;
}



@end
