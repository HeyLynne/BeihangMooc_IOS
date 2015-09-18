//
//  MOOCMyCourseSplitView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-17.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCMyCourseSplitView.h"
#

@interface MOOCMyCourseSplitView ()

@end

@implementation MOOCMyCourseSplitView

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
    NSLog(@"%@",self.viewControllers);
    _list = [[(UINavigationController *)[[self viewControllers] objectAtIndex:0] childViewControllers] objectAtIndex:0];
    _show = [[(UINavigationController *)[[self viewControllers] objectAtIndex:1] childViewControllers] objectAtIndex:0];
    self.delegate = _show;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_show.player||!_show.player.readyForDisplay)
    {
        [super viewWillAppear:animated];
        [_list refreshCourse];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
