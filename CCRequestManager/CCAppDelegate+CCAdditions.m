//
//  CCAppDelegate+Addition.m
//  CCRQMG
//
//  Created by Chun Cao on 12-10-8.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import "CCAppDelegate+CCAdditions.h"

@implementation CCAppDelegate (CCAdditions)

#pragma mark -
#pragma mark Shared resources

- (NSDictionary *)appConfig {
    if (!_appConfig) {
        NSString * mainFile = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
        _appConfig = [[NSDictionary alloc] initWithContentsOfFile:mainFile];
        DLog(@"current app config dictionary: %@", [_appConfig description]);
    }
    return _appConfig;
}

- (void)showNetworkActivityIndicator {
    networkActivityRefCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    DLog(@"network indicator ++ %d", networkActivityRefCount);
}

- (void)hideNetworkActivityIndicator {
    if (networkActivityRefCount > 0) {
        networkActivityRefCount--;
        NSLog(@"network indicator -- %d", networkActivityRefCount);
    }
    if (networkActivityRefCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
