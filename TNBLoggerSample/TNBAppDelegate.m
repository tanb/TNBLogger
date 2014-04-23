//
//  TNBAppDelegate.m
//  TNBLoggerSample
//
//  Created by tanB on 2/26/14.
//  Copyright (c) 2014 tanb. All rights reserved.
//

#import "TNBAppDelegate.h"
TNBLogger *logger;

@implementation TNBAppDelegate

+ (void)initialize
{
    NSString *appBundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    NSString *logPath = [NSString stringWithFormat:@"/Users/%@/Desktop", NSUserName()];

    NSString *fileName = [NSString stringWithFormat:@"%@.log", appBundleID];
    NSString *logFilePath = [logPath stringByAppendingPathComponent:fileName];
#if DEBUG
    logger = [[TNBLogger alloc] initWithOutputFilePath:logFilePath filterLevel:ASL_LEVEL_DEBUG];
#else
    logger = nil;
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [logger debug:@"%@", NSStringFromSelector(_cmd)];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
