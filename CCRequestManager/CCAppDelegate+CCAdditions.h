//
//  CCAppDelegate+Addition.h
//  CCRQMG
//
//  Created by Chun Cao on 12-10-8.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import "CCAppDelegate.h"

#define CC_SHARED_APP_DELEGATE() (CCAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface CCAppDelegate (CCAdditions)


- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;

@property (nonatomic, readonly) NSDictionary *appConfig;

@end
