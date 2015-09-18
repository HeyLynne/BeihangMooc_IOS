//
//  MOOCChapterList.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-25.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCChapterList.h"
#import "MOOCSectionList.h"

@interface MOOCChapterList ()

@end

@implementation MOOCChapterList
@synthesize courseId=_courseId;

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
    self.navigationItem.title = [NSString stringWithFormat:@"章节列表 － %@",[_courseInfo objectForKey:@"display_name"]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    //NSLog(@"%@",_courseList);
    //NSLog(@"%@",[_courseList objectForKey:@"display_name"]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chapterList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_chapterList objectAtIndex:indexPath.row];
    //NSLog(@"%@",dict);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[dict objectForKey:@"url_name"]];
    cell.textLabel.text = [dict objectForKey:@"display_name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [_chapterList objectAtIndex:indexPath.row];
    NSArray *arr = [dict objectForKey:@"sections"];
    if ([arr count])
    {
        [self performSegueWithIdentifier:@"chaptertoSection" sender:arr];
    }
    else
    {
        //NSLog(@"Disabled");
        [[[UIAlertView alloc] initWithTitle:@"此列表下无视频" message:@"请稍后重试或查看其他课程" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil] show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MOOCSectionList *view = [segue destinationViewController];
    view.sectionList = (NSArray *)sender;
    view.courseInfo = _courseInfo;
    view.courseId=_courseId;
    // Pass the selected object to the new view controller.
}


@end
