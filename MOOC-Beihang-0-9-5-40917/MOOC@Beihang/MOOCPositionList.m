//
//  MOOCPositionList.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-25.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCPositionList.h"
#import "MOOCMyCourseShow.h"
#import "MoocIphoneCourseShow.h"
#import "MOOCConnection.h"

@interface MOOCPositionList ()
@end

@implementation MOOCPositionList

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = [NSString stringWithFormat:@"视频列表 - %@",[_courseInfo objectForKey:@"display_name"]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_videoList objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[dict objectForKey:@"address"]];
    NSString *title = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
    cell.textLabel.text = title;
    return cell;
}

#warning 在MOOCUrlProcessing中isHTTPUrl是一个正则表达式判断是否是http//mooc.buaa.edu.cn……之类的表达如果服务器主机变了应该相应的正则表达式判断也要变！！！
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        //if内容
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *dict = [_videoList objectAtIndex:indexPath.row];
        MOOCMyCourseShow *target = nil;
        NSArray *arr = self.splitViewController.childViewControllers;
        for (UINavigationController *nav in arr)
        {
            for (id v in nav.childViewControllers)
            {
                if ([v isKindOfClass:[MOOCMyCourseShow class]])
                {
                    target = v;
                }
            }
        }
        NSLog(@"%@",dict);
        NSString *address=[dict objectForKey:@"address"];
        MOOCUrlProcessing *urlProcessor=[[MOOCUrlProcessing alloc]init];
        if(!([urlProcessor isHTTPUrl:address])){
            address=[urlProcessor patternUrl:address];
        }
        address=[address stringByRemovingPercentEncoding];
        address=[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:address];
        NSString *subtitle_url=[dict objectForKey:@"subtitles_url"];
        subtitle_url=[subtitle_url stringByRemovingPercentEncoding];
        subtitle_url=[subtitle_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (target)
        {
            target.subtitlesUrl=subtitle_url;
            [target playMovieWithURL:url];
        }
    }
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *dict = [_videoList objectAtIndex:indexPath.row];
        //NSLog(@"%@",dict);
        NSString *subtitle_url=[dict objectForKey:@"subtitles_url"];
        subtitle_url=[subtitle_url stringByRemovingPercentEncoding];
        subtitle_url=[subtitle_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        subtitle_url=[self getSubtitleLocalUrl:subtitle_url];
        NSString *address=[dict objectForKey:@"address"];
        MOOCUrlProcessing *urlProcessor=[[MOOCUrlProcessing alloc]init];
        if(!([urlProcessor isHTTPUrl:address])){
            address=[urlProcessor patternUrl:address];
        }
        address=[address stringByRemovingPercentEncoding];
        address=[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:address];
        UIStoryboard *storyboard=self.storyboard;
        MoocIphoneCourseShow *iphoneCourseShow=[storyboard instantiateViewControllerWithIdentifier:@"IphoneCourseShow"];
        [iphoneCourseShow setUpUrl:url];
        iphoneCourseShow.subtitleUrl=subtitle_url;
        [self.navigationController presentViewController:iphoneCourseShow animated:YES completion:nil];
    }
}

//在这里实现对subtitle的存储和路径获取。最好的是异步但是需要确定十几，这个我不清楚。
-(NSString*)getSubtitleLocalUrl:(NSString *)subtitle_url
{
    NSURL    *url = [NSURL URLWithString:subtitle_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData   *data = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *path = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss-SSS"];
    int lengthOfString = 4;
    char string[lengthOfString];
    for (int x=0; x<lengthOfString; string[x++] = (char)('a'+(arc4random_uniform(26))));
    NSString *randname = [[NSString alloc] initWithBytes:string length:lengthOfString encoding:NSUTF8StringEncoding];
    NSString *datename = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"%@-%@",datename,randname];
    NSString *fullpath = [NSString stringWithFormat:@"%@%@.srt",[path path],filename];
    BOOL success = [fileManager createFileAtPath:fullpath contents:data attributes:nil];
    if(success){
        return fullpath;
    }
    else{
        return @"";
    }
}

@end
