//
//  MOOCForumDiscussion.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/4/24.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCForumDiscussion.h"
#import "MOOCActivityIndicator.h"
#import "MOOCConnection.h"
#import "SBJson.h"
#import "MOOCForumDetails.h"
#import "MOOCaddTheThread.h"

#define REFRESH_HEADER_HEIGHT 20.0f

@interface MOOCForumDiscussion ()
{
    MOOCActivityIndicator *prog;
    BOOL isAlertViewExist;
    NSString *textPull;
    NSString *textLoading;
    NSString *textNoMore;
    NSString *textRelease;
    int totalPages;
    int currentPage;
    UIView *refreshFooterView;
    UILabel *refreshLabel;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isLoading;
    BOOL hasmore;
    BOOL isdraging;
}

@end

@implementation MOOCForumDiscussion
@synthesize cid=_cid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isAlertViewExist = NO;
    _discussions=[[NSMutableArray alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.navigationItem.title=@"课程讨论";
    textPull=@"上拉加载更多";
    textLoading=@"正在加载……";
    textNoMore=@"没有更多内容了";
    textRelease=@"松开即可刷新";
    currentPage=1;
    totalPages=0;
    [[MOOCConnection sharedInstance] MOOCGetForumDiscussionData:_cid];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromForumDiscussions:) name:sMOOCGetForumDiscussionData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFromThreadAlready:) name:sMOOCCreateThreadAlready object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPages:) name:sMOOCGetPageForum object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_discussions count];
}

-(void)receiveNotificationFromForumDiscussions:(NSNotification *)noti
{
    NSDate *date=[NSDate date];
    [_discussions removeAllObjects];
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        NSString *cdiscussions=[noti.userInfo objectForKey:@"threads"];
        SBJsonParser *jsonParser=[[SBJsonParser alloc] init];
        _user_info=[[NSMutableDictionary alloc]initWithDictionary:[jsonParser objectWithString:[noti.userInfo objectForKey:@"user_info"]]];
        totalPages=[[noti.userInfo objectForKey:@"thread_pages"] intValue];
        NSMutableDictionary *ddiscussions=[jsonParser objectWithString:cdiscussions];
        if([ddiscussions count]>0){
            for (NSDictionary *oldDiscussion in ddiscussions){
                NSString *disId=[oldDiscussion objectForKey:@"id"];
                bool can_reply=[[[[jsonParser objectWithString:[noti.userInfo objectForKey:@"annotated_content_info"]] objectForKey:disId] objectForKey:@"ability"] objectForKey:@"can_reply"];
                NSMutableDictionary *target=[NSMutableDictionary dictionaryWithDictionary:oldDiscussion];
                if(can_reply){
                    [target setObject:@"1" forKey:@"can_reply"];
                }
                else {
                    [target setObject:@"0" forKey:@"can_reply"];
                }
                [_discussions addObject:target];
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"无讨论" message:@"讨论区无数据" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            });
        }
    }
    else{
        NSDictionary *recv=noti.userInfo;
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code=[[recv objectForKey:@"statusCode"] intValue];
        if(code != 200){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!isAlertViewExist){
                    [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后尝试刷新本页面。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
                    isAlertViewExist=YES;
                }
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if(totalPages>1){
            hasmore=true;
            refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height+20, 320, REFRESH_HEADER_HEIGHT)];
            refreshFooterView.backgroundColor = [UIColor clearColor];
            
            refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
            refreshLabel.backgroundColor = [UIColor clearColor];
            refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
            refreshLabel.textAlignment = UITextAlignmentCenter;
            refreshLabel.text=textPull;
            
            refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 10) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
            refreshSpinner.hidesWhenStopped = YES;
            
            [refreshFooterView addSubview:refreshLabel];
            [refreshFooterView addSubview:refreshSpinner];
            self.tableView.tableFooterView = refreshFooterView;
            //[self.tableView addSubview:refreshFooterView];
            [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
            //[self.tableView setContentInset:(UIEdgeInsetsMake(0, 0,REFRESH_HEADER_HEIGHT, 0))];
        }
        else{
            hasmore=false;
        }
    });
    NSLog(@"Get Forum-Discussion complete,Elapsed time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForumTableCell" forIndexPath:indexPath];
    NSDictionary *dict=_discussions[indexPath.row];
    UILabel *label;
    label=(UILabel *)[cell viewWithTag:1];
    label.text=[dict objectForKey:@"title"];
    label=(UILabel *)[cell viewWithTag:2];
    label.text=[dict objectForKey:@"username"];
    label=(UILabel *)[cell viewWithTag:3];
    NSString *aContent=[dict objectForKey:@"body"];
    if([aContent length]>=34){
        label.text=[[aContent substringToIndex:30] stringByAppendingString:@"……"];
    }
    else{
        label.text=aContent;
    }
    label=(UILabel *)[cell viewWithTag:4];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *update_time=[formatter dateFromString:[dict objectForKey:@"updated_at"]];
   // NSDate *update_time=[formatter dateFromString:@"2012-05-23 13:06:51.394+1000"];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    label.text=[formatter stringFromDate:update_time];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"forumDetails" sender:[self.tableView indexPathForSelectedRow]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isdraging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading && scrollView.contentOffset.y > 0) {
        // Update the content inset, good for section headers
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT, 0);
    }else if(!hasmore){
        refreshLabel.text = textNoMore;
    }else if (isdraging && scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= 0 ) {
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT) {
           refreshLabel.text =textRelease;
        } else {
            refreshLabel.text = textPull;
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading || !hasmore) return;
    isdraging = NO;
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = textLoading;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0;
    self.tableView.contentInset = tableContentInset;
    [UIView commitAnimations];
}

- (void)refresh {
    currentPage=currentPage+1;
    if(currentPage<=totalPages){
        [[MOOCConnection sharedInstance] MOOCGEtPageForumData:_cid pageNum:currentPage];
    }
    else{
        [self performSelector:@selector(stopLoading) withObject:nil];
        hasmore=false;
    }
    
}

-(void)refreshPages:(NSNotification *)noti
{
    NSDate *date=[NSDate date];
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        NSString *cdiscussions=[noti.userInfo objectForKey:@"threads"];
        SBJsonParser *jsonParser=[[SBJsonParser alloc] init];
        _user_info=[[NSMutableDictionary alloc]initWithDictionary:[jsonParser objectWithString:[noti.userInfo objectForKey:@"user_info"]]];
        //currentPage=[[noti.userInfo objectForKey:@"thread_pages"] intValue];
        NSMutableDictionary *ddiscussions=[jsonParser objectWithString:cdiscussions];
        if([ddiscussions count]>0){
            for (NSDictionary *oldDiscussion in ddiscussions){
                NSString *disId=[oldDiscussion objectForKey:@"id"];
                bool can_reply=[[[[jsonParser objectWithString:[noti.userInfo objectForKey:@"annotated_content_info"]] objectForKey:disId] objectForKey:@"ability"] objectForKey:@"can_reply"];
                NSMutableDictionary *target=[NSMutableDictionary dictionaryWithDictionary:oldDiscussion];
                if(can_reply){
                    [target setObject:@"1" forKey:@"can_reply"];
                }
                else {
                    [target setObject:@"0" forKey:@"can_reply"];
                }
                [_discussions addObject:target];
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"无讨论" message:@"无数据" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            });
        }
    }
    else{
        NSDictionary *recv=noti.userInfo;
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code=[[recv objectForKey:@"statusCode"] intValue];
        if(code != 200){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!isAlertViewExist){
                    [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后尝试刷新本页面。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
                    isAlertViewExist=YES;
                }
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if(currentPage==totalPages){
            hasmore=false;
        }
        else{
            hasmore=true;
        }
        [self performSelector:@selector(stopLoading) withObject:nil];
    });
    NSLog(@"Get Forum-Discussion complete,Elapsed time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    NSLog(@"%f",self.tableView.contentSize.height);
    
    refreshLabel.text = textPull;
    
    [refreshFooterView setFrame:CGRectMake(0, self.tableView.contentSize.height, 320, 0)];
    
    [refreshSpinner stopAnimating];
}

-(void) performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"forumDetails"]){
        MOOCForumDetails *view=[segue destinationViewController];
        NSMutableDictionary *dict=[_discussions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        NSMutableDictionary *details=[[NSMutableDictionary alloc] init];
        [details setObject:[dict objectForKey:@"created_at"] forKey:@"created_at"];
        [details setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
        [details setObject:[dict objectForKey:@"course_id"] forKey:@"course_id"];
        [details setObject:[dict objectForKey:@"commentable_id"] forKey:@"discussion_id"];
        [details setObject:[dict objectForKey:@"id"] forKey:@"thread_id"];
        [details setObject:[dict objectForKey:@"username"] forKey:@"username"];
        [details setObject:[dict objectForKey:@"body"] forKey:@"body"];
        [details setObject:[dict objectForKey:@"title"] forKey:@"title"];
        [details setObject:[dict objectForKey:@"can_reply"] forKey:@"can_reply"];
        [details setObject:[dict objectForKey:@"comments_count"] forKey:@"comments_count"];
        [details setObject:_user_info forKey:@"user_info"];
        //NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)sender];
        view.discussionContent=details;
    }
    else if([[segue identifier] isEqualToString:@"toAddAThread"]){
        MOOCaddTheThread *view=[segue destinationViewController];
        NSMutableDictionary *dict=[_discussions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        NSMutableDictionary *details=[[NSMutableDictionary alloc] init];
        [details setObject:[dict objectForKey:@"course_id"] forKey:@"course_id"];
        [details setObject:[dict objectForKey:@"commentable_id"] forKey:@"discussion_id"];
        view.recvInfo=details;
    }
}

- (IBAction)dismissButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addAThread:(id)sender {
    [self performSegueWithIdentifier:@"toAddAThread" sender:self];
}

-(void)receiveFromThreadAlready:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MOOCConnection sharedInstance] MOOCGetForumDiscussionData:_cid];
    });
}
@end
