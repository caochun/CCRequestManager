//
//  CCAppDelegate.h
//  CCRequestManager
//
//  Created by Chun Cao on 12-10-8.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRequest.h"

@interface CCAppDelegate : UIResponder <UIApplicationDelegate>{
    NSInteger networkActivityRefCount;
    NSDictionary *_appConfig;

}

@property (strong, nonatomic) UIWindow *window;

@end
