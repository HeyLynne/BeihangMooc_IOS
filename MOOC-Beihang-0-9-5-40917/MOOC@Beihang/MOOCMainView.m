//
//  MOOCMainView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-20.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCMainView.h"

@interface MOOCMainView ()

@end

@implementation MOOCMainView

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
    //NSLog(@"%@",self.childViewControllers);
    _mView = [[self viewControllers] objectAtIndex:0];
    UINavigationController* _uView = (UINavigationController *)[[self viewControllers] objectAtIndex:1];
    _cView = [[_uView childViewControllers] objectAtIndex:0];
    //_sView = [[(UINavigationController *)[[self viewControllers] objectAtIndex:2] childViewControllers] objectAtIndex:0];
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    if(![[save objectForKey:@"isLogin"] boolValue])
    {
        UITabBarItem *item = [[self.tabBar items] objectAtIndex:0];
        [item setTitle:@"登录"];
        self.selectedIndex = 0;
        
        //dede
    }
    else
    {
        self.selectedIndex = 0;
    }
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //int type = (int)tabBarController.selectedIndex;
    int type = (int)tabBarController.selectedIndex;
    //NSLog(@"%d",type);
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    if(type == 0&&![[save objectForKey:@"isLogin"] boolValue])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)switchViewTo:(int)index
{
    if (index>=0 && index<=2)
    {
        self.selectedIndex = index;
    }
}

-(BOOL) shouldAutorotate{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        return NO;
    }
    else
        return YES;
}
@end
