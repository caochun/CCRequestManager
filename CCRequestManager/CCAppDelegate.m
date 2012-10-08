//
//  CCAppDelegate.m
//  CCRequestManager
//
//  Created by Chun Cao on 12-10-8.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import "CCAppDelegate.h"
#import "JSONKit.h"

@implementation CCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSString *jsonStr= @"[{\"nid\":\"4\",\"type\":\"news\",\"language\":\"\",\"uid\":\"1\",\"status\":\"1\",\"created\":\"1345262039\",\"changed\":\"1349348947\",\"comment\":\"2\",\"promote\":\"1\",\"moderate\":\"0\",\"sticky\":\"0\",\"tnid\":\"0\",\"translate\":\"0\",\"vid\":\"4\",\"revision_uid\":\"1\",\"title\":\"news2\",\"body\":\"something big is gonna happen\",\"teaser\":\"something big is gonna happen\",\"log\":\"\",\"revision_timestamp\":\"1349348947\",\"format\":\"1\",\"name\":\"admin\",\"picture\":\"\",\"data\":\"a:0:{}\",\"path\":\"content/news2\",\"signup\":0,\"last_comment_timestamp\":\"1345262039\",\"last_comment_name\":null,\"comment_count\":\"0\",\"taxonomy\":[],\"uuid\":false,\"revision_uuid\":\"eaa21918-0e13-11e2-958c-f23c91dfeecb\"},{\"nid\":\"3\",\"type\":\"news\",\"language\":\"\",\"uid\":\"1\",\"status\":\"1\",\"created\":\"1345262012\",\"changed\":\"1345262012\",\"comment\":\"2\",\"promote\":\"1\",\"moderate\":\"0\",\"sticky\":\"0\",\"tnid\":\"0\",\"translate\":\"0\",\"vid\":\"3\",\"revision_uid\":\"1\",\"title\":\"news1\",\"body\":\"this is the first news\",\"teaser\":\"this is the first news\",\"log\":\"\",\"revision_timestamp\":\"1345262012\",\"format\":\"1\",\"name\":\"admin\",\"picture\":\"\",\"data\":\"a:0:{}\",\"path\":\"content/news1\",\"signup\":0,\"last_comment_timestamp\":\"1345262012\",\"last_comment_name\":null,\"comment_count\":\"0\",\"taxonomy\":[],\"uuid\":false,\"revision_uuid\":false}]";
    NSLOG(@"%@",(NSDictionary *)[jsonStr objectFromJSONString]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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
