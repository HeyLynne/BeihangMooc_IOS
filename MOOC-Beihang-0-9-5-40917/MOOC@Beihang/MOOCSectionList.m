//
//  MOOCSectionList.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-25.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCSectionList.h"
#import "MOOCPositionList.h"

@interface MOOCSectionList ()

@end

@implementation MOOCSectionList
@synthesize courseId=_courseId;
NSString *vsubttitles_en;

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
    self.navigationItem.title = [NSString stringWithFormat:@"小节列表 － %@",[_courseInfo objectForKey:@"display_name"]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSMutableArray *newList = [NSMutableArray arrayWithArray:_sectionList];
    for (NSDictionary *dict in _sectionList)
    {
        //遍历unit内元素
        int index = [_sectionList indexOfObject:dict];
        NSMutableArray *unit = [dict objectForKey:@"units"];
        NSMutableDictionary *unitAfter = [[NSMutableDictionary alloc] init];
        NSMutableArray *newVideo = [[NSMutableArray alloc] init];
        [unitAfter setObject:[dict objectForKey:@"display_name"] forKey:@"display_name"];
        if ([unit count])
        {
            int videoCount = 1;
            for (NSDictionary *u in unit)
            {
                NSMutableArray *uu = [u objectForKey:@"verticals"];
                //遍历元素内小元素
                for (NSDictionary *p in uu)
                {
                    if ([p objectForKey:@"name"])
                    {
                        MOOCUrlProcessing *urlProcessor=[[MOOCUrlProcessing alloc] init];
                        NSString *v = [p objectForKey:@"type"];
                        NSMutableDictionary *vSubtitles=[p objectForKey:@"subtitles"];
                        vsubttitles_en=[vSubtitles objectForKey:@"zh"];
                        if([vsubttitles_en length]>0){
                            vsubttitles_en=[urlProcessor patternSrtUrl:vsubttitles_en courseid:_courseId];
//                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                [[MOOCConnection sharedInstance] MOOCGetSubtitles:vsubttitles_en] ;
//                            });
                            
                        }
                        else{
                            vsubttitles_en=@"";
                        }
                        //如果v是视频
                        if ((v)&&(![v isEqualToString:@"non-video"]))
                        {
                            NSArray *vv = [p objectForKey:@"video_sources"];
                            if ([vv count])
                            {
                                for (NSString *addr in vv)
                                {
                                    NSDictionary *add = @{@"name": [NSString stringWithFormat:@"video%d",videoCount], @"address":addr,@"subtitles_url":vsubttitles_en};
                                    [newVideo addObject:add];
                                    videoCount++;
                                }
                            }
                        }
                    }
                }
            }
        }
        [unitAfter setObject:newVideo forKey:@"video"];
        [newList replaceObjectAtIndex:index withObject:unitAfter];
    }
    _sectionList = newList;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sectionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_sectionList objectAtIndex:indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[dict objectForKey:@"display_name"]];
    cell.textLabel.text = [dict objectForKey:@"display_name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [_sectionList objectAtIndex:indexPath.row];
    if ([[dict objectForKey:@"video"] count])
    {
        [self performSegueWithIdentifier:@"sectiontoPosition" sender:[dict objectForKey:@"video"]];
    }
    else
    {
        //NSLog(@"Disabled");
        [[[UIAlertView alloc] initWithTitle:@"此列表下无视频" message:@"请稍后重试或查看其他课程" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil] show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MOOCPositionList *view = [segue destinationViewController];
    view.videoList = (NSArray *)sender;
    view.courseInfo = _courseInfo;
}


@end
