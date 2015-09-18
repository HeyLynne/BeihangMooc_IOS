//
//  MOOCDatabaseCourse.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-31.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOOCDatabaseCourse : NSManagedObject

@property (nonatomic, retain) NSString * sections;
@property (nonatomic, retain) NSDate * enrollment_end;
@property (nonatomic, retain) NSDate * enrollment_date;
@property (nonatomic, retain) NSDate * enrollment_start;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSDate * course_start;
@property (nonatomic, retain) NSString * course_title;
@property (nonatomic, retain) NSDate * course_end;
@property (nonatomic, retain) NSString * course_image;
@property (nonatomic, retain) NSString * course_image_url;
@property (nonatomic, retain) NSString * course_id;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSNumber * registered;
@property (nonatomic, retain) NSNumber * is_full;
@property (nonatomic, retain) NSString * display_name;
@property (nonatomic, retain) NSString * display_number;
@property (nonatomic, retain) NSString * display_organization;

@end
