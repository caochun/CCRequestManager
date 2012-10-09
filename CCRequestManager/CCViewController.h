//
//  CCViewController.h
//  CCRequestManager
//
//  Created by Chun Cao on 12-10-9.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCRequest.h"

@interface CCViewController : UIViewController<CCRequestDelegate>

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UITextView *logText;

-(IBAction)doLoad:(id)sender;

@end
