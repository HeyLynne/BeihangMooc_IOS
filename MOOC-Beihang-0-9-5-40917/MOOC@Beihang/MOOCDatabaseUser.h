//
//  MOOCDatabaseUser.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-31.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOOCDatabaseUser : NSManagedObject

@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_full_name;
@property (nonatomic, retain) NSString * language_code;
@property (nonatomic, retain) NSString * mail_address;
@property (nonatomic, retain) NSDate * last_update;

@end
