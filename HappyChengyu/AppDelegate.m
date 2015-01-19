//
//  AppDelegate.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "AppDelegate.h"
#import "FavoritesHelper.h"
#import <iflyMSC/IFlySpeechUtility.h>
#import <VCTransitionsLibrary/CECrossfadeAnimationController.h>

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 指定Tab Bar Controller的delegate
    UITabBarController *tabBarController = (UITabBarController *)(self.window.rootViewController);
    tabBarController.delegate = self;
    
    // 初始化语音朗读和语音识别组件
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@, timeout=%@",@"54b4720d", @"20000"];
    [IFlySpeechUtility createUtility:initString];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FavoritesHelper sharedInstance] saveFavorites];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark <UITabBarControllerDelegate>

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    CEReversibleAnimationController *animator = [CECrossfadeAnimationController new];
    animator.duration = 0.5;
    animator.reverse = fromVCIndex < toVCIndex;
    return animator;
//    return nil;
}

@end
