//
//  CCAppDelegate+Addition.m
//  CCRQMG
//
//  Created by Chun Cao on 12-10-8.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import "CCAppDelegate+Additions.h"

@implementation CCAppDelegate (Additions)


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
