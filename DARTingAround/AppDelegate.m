//
//  AppDelegate.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <TSMessages/TSMessage.h>

@interface AppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate>
@end

@implementation AppDelegate

- (void)customiseAppearance {
    LogIt(@"customiseAppearance");
    self.window.tintColor = UIColorFromRGB(COLOUR_LIGHT_GREEN);
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(COLOUR_LIGHT_GREEN)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:UIColorFromRGB(COLOUR_DARK_BLUE)}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LogIt(@"application didFinishLaunchingWithOptions");
    // HockeyApp
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:HOCKEY_TEST
                                                         liveIdentifier:HOCKEY_LIVE
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    //
    [self configureReachability];
    //
    [self customiseAppearance];
    //
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    LogIt(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    LogIt(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    LogIt(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    LogIt(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    LogIt(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    LogIt(@"customDeviceIdentifierForUpdateManager");
#ifndef CONFIGURATION_Release
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

#pragma mark - Reachability

- (void)configureReachability {
    LogIt(@"configureReachability");
//    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager managerForDomain:@"http://api.irishrail.ie/realtime/"];
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                LogIt(@"configureReachability :: No Internet Connection");
                [TSMessage showNotificationInViewController:self.window.rootViewController
                                                      title:@"No internet connection"
                                                   subtitle:@"I couldn't connect to the train data service. Either it is offline or you are not connected to the internet."
                                                       type:TSMessageNotificationTypeError
                                                   duration:3.0
                                                   callback:^{}
                                                buttonTitle:nil
                                             buttonCallback:^{}
                                                 atPosition:TSMessageNotificationPositionTop
                                        canBeDismisedByUser:YES];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                LogIt(@"configureReachability :: WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                LogIt(@"configureReachability :: 3G");
                break;
            default:
                LogIt(@"configureReachability :: Unknown network status");
                break;
        }
    }];
    [reachability startMonitoring];
}

@end
