
//
//  MOOCCommentDetails.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/7.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCCommentDetails.h"
#import "MOOCConnection.h"

@interface MOOCCommentDetails ()
@property NSMutableDictionary *postInfo;
@end

@implementation MOOCCommentDetails

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_prog startAnimating];
    _comments=[[NSMutableArray alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.navigationItem.title=@"回复详情";
    [[MOOCConnection sharedInstance] MOOCGetDiscussionDetail:_requstInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCommentContents:) name:sMOOCGetDiscussionDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFromReplyACommentAlready:) name:sMOOCReplyCommentAlready object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    //NSLog(@"indexpath:%p, %d",indexPath, indexPath.row);
    //NSLog(@"2");
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static UITableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    });
    //NSLog(@"1");
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    UILabel *label=[sizingCell viewWithTag:3];
    return label.frame.size.height+label.frame.origin.y+5.0;
}

- (void)configureBasicCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _comments[indexPath.row];
    UILabel *label=[cell viewWithTag:1];
    label.text=[dict objectForKey:@"username"];
    label=[cell viewWithTag:2];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *created_time=[formatter dateFromString:[dict objectForKey:@"created_at"]];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    label.text=[formatter stringFromDate:created_time];
    label=[cell viewWithTag:3];
    NSString *ltext;
    if(![[dict objectForKey:@"is_parent_comment"] boolValue]){
        ltext=[NSString stringWithFormat:@"回复%@: %@",[dict objectForKey:@"parent_username"],[dict objectForKey:@"body"]];
    }
    else{
        ltext=[NSString stringWithFormat:@"%@说: %@",[dict objectForKey:@"username"],[dict objectForKey:@"body"]];
    }
    label.text=ltext;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict=_comments[indexPath.row];
    if([[dict objectForKey:@"is_parent_comment"] boolValue]){
        if([_postInfo count]==0){
            _postInfo=[[NSMutableDictionary alloc] init];
            [_postInfo setObject:[dict objectForKey:@"course_id"] forKey:@"course_id"];
            [_postInfo setObject:[dict objectForKey:@"id"] forKey:@"comment_id"];
        }
        else{
            [_postInfo removeAllObjects];
            [_postInfo setObject:[dict objectForKey:@"course_id"] forKey:@"course_id"];
            [_postInfo setObject:[dict objectForKey:@"id"] forKey:@"comment_id"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:nil	 delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复", nil];
            actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionsheet showInView:self.tableView];
        });
    }
}

-(void)receiveCommentContents:(NSNotification *)noti
{
    NSDate *date=[[NSDate alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{[_prog stopAnimating];[_prog removeFromSuperview];});
    NSDictionary *dict=noti.userInfo;
    if([[dict objectForKey:@"status"] boolValue]){
        NSMutableArray *allComments=[[NSMutableArray alloc] init];
        NSArray *recvComment=[[dict objectForKey:@"thread"] objectForKey:@"children"];
        for(NSDictionary *aComment in recvComment){
            NSMutableDictionary *tempComment=[[NSMutableDictionary alloc] initWithDictionary:aComment];
            [tempComment setObject:@"1" forKey:@"is_parent_comment"];
            [tempComment setObject:@"" forKey:@"parent_id"];
            [tempComment setObject:@"" forKey:@"parent_user                                                                                                                                                                                                                                                                                                        name"];
            [allComments addObject:tempComment];
            if([[tempComment objectForKey:@"children"] count]>0){
                for(NSDictionary *childComment in [tempComment objectForKey:@"children"]){
                    NSMutableDictionary *tempChildComment=[[NSMutableDictionary alloc] initWithDictionary:childComment];
                    [tempChildComment setObject:@"0" forKey:@"is_parent_comment"];
                    [tempChildComment setObject:[tempComment objectForKey:@"id"] forKey:@"parent_id"];
                    [tempChildComment setObject:[tempComment objectForKey:@"username"] forKey:@"parent_username"];
                    [allComments addObject:tempChildComment];
                }
            }
        }
        _comments=allComments;
    }
    else{
        NSDictionary *recv=noti.userInfo;
        NSLog(@"Errorcode:%@,Error:%@,When get discussiondetails",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code=[[recv objectForKey:@"statusCode"] intValue];
        if(code != 200){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后重试。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
    NSLog(@"Notification @MOOCCommentDetails complete,Elapsed Time %f",[[NSDate date] timeIntervalSinceDate:date]);
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        MOOCReplyAComment *replyView=[self.storyboard instantiateViewControllerWithIdentifier:@"reaplyAComment"];
        replyView.postInfo=_postInfo;
        [self presentViewController:replyView animated:YES completion:nil];
    }
}

-(void)receiveFromReplyACommentAlready:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MOOCConnection sharedInstance] MOOCGetDiscussionDetail:_requstInfo];
    });
}
@end
