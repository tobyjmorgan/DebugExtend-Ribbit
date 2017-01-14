//
//  AppDelegate.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FIRApp configure];
    
    // Thanks to buczek on StackOverflow
    // http://stackoverflow.com/questions/25845855/transparent-navigation-bar-ios
    
    // Sets background to a blank/empty image
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    // Sets shadow (line below the bar) to a blank image
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    // Sets the translucent background color
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:160.0/255.0 green:133.0/255.0 blue:198.0/255.0 alpha:1.0]];
    // Set translucent. (Default value is already true, so this can be removed if desired.)
    [UINavigationBar appearance].translucent = YES;
    // Set font color of navigation bar
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];


    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:160.0/255.0 green:133.0/255.0 blue:198.0/255.0 alpha:1.0]];
    [UITabBar appearance].translucent = YES;
    [UITabBar appearance].tintColor = [UIColor whiteColor];
    [UITabBar appearance].unselectedItemTintColor = [UIColor darkGrayColor];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
