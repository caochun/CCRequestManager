//
//  CCViewController.m
//  CCRequestManager
//
//  Created by Chun Cao on 12-10-9.
//  Copyright (c) 2012年 Nemoworks. All rights reserved.
//

#import "CCViewController.h"
#import "CCRequest.h"
#import "CCRequestManager.h"

@interface CCViewController ()

@end

@implementation CCViewController

-(IBAction)doLoad:(id)sender{
//    CCRequest *request = [[CCRequestManager sharedManager] requestResourceWithDelegate:self resourcePath:@"views/news" params:nil];
    CCRequest *request = [[CCRequestManager sharedManager] requestURLWithDelegate:self rawUrl:[NSURL URLWithString:@"http://nemoworks.info/kurogo/rest/map/index"] params:nil];
    [request connectWithCache:YES];
    return;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestWillTerminate:(CCRequest *)request{
    return;
}


- (void)request:(CCRequest *)request didReceiveResult:(id)result{
    self.logText.text=@"done";

}

@end
