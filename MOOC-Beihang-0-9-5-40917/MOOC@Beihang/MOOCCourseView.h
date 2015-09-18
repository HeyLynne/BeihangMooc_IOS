//
//  MOOCCourseView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-6.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIColor.h>
#import "MOOCQRCodeView.h"

@interface MOOCCourseView : UICollectionViewController <UISearchBarDelegate, UIAlertViewDelegate>
{
    
}
//@property (nonatomic, strong) UISearchBar *search;

//@property (weak) UIPopoverController *popoverView;
@property (atomic, retain) NSMutableArray *collectionArr;
@property NSString *recvStr;
@end
