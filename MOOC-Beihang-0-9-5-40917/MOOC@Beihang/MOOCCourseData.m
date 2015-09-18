//
//  MOOCCourseData.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-31.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCCourseData.h"

__strong static MOOCCourseData *sharedInstance = nil;

@interface MOOCCourseData ()
{
    NSUserDefaults *save;
}
- (NSArray *)getDataInTable:(NSString *)table Predicate:(NSPredicate *)predicate;
- (NSDictionary *)deleteUselessDict:(NSDictionary *)dict;

@end

@implementation MOOCCourseData

- (id)init
{
    if (self = [super init])
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
        context = appDelegate.managedObjectContext;
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        lock = [[NSLock alloc] init];
        save = [NSUserDefaults standardUserDefaults];
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    return sharedInstance;
}


- (BOOL)insertCourseWithData:(NSDictionary *)idict
{
    //新建的时候数据一定较少，只更新title、start、display2个、id、imgurl
    NSDictionary *dict = [self deleteUselessDict:idict];
    NSString *cid = [dict objectForKey:sMOOCCourseID];
    NSString *predStr = [NSString stringWithFormat:@"course_id like '%@'", cid];
    NSArray *arr = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:[NSPredicate predicateWithFormat:predStr]];
    if (arr && [arr count])
    {
        NSLog(@"A Course %@ Exists - Will Update", cid);
        return [self updateCourse:cid withData:dict];
    }
    MOOCDatabaseCourse *course = [NSEntityDescription insertNewObjectForEntityForName:@"MOOCDatabaseCourse" inManagedObjectContext:context];
    if (course)
    {
        for (NSString *obj in dict)
        {
            if (![obj isEqualToString:@"active"]&&![obj isEqualToString:@"advertised_start"]&&![obj isEqualToString:@"status"]&&![obj isEqualToString:@"error"])
            {
                NSString *value = [dict objectForKey:obj];
                if (value)
                {
                    if ([obj isEqualToString:@"enrollment_date"] || [obj isEqualToString:@"enrollment_start"] || [obj isEqualToString:@"enrollment_end"] || [obj isEqualToString:@"course_start"] || [obj isEqualToString:@"course_end"])
                    {
                        NSDate *date = [format dateFromString:value];
                        if (date)
                            [course setValue:date forKey:obj];
                    }
                    else
                    {
                        [course setValue:value forKey:obj];
                    }
                }
            }
        }
        course.last_update = [NSDate date];
        NSError *err = nil;
        
        [lock lock];
        BOOL isSuccess = [context save:&err];
        [lock unlock];
        
        if (isSuccess) return YES;
        else
        {
            NSLog(@"Error When Creating Course %@ - %@", cid, [err localizedDescription]);
            return NO;
        }
    }
    else
    {
        NSLog(@"Fatal Error: Fail to creating MOOCDatabaseCourse object for course %@", cid);
        return NO;
    }
}

- (BOOL)insertUserInfoWithData:(NSDictionary *)idict
{
    NSDictionary *dict = [self deleteUselessDict:idict];
    NSArray *arr = [self getDataInTable:@"MOOCDatabaseUser" Predicate:nil];
    if (arr && [arr count])
    {
        NSLog(@"An UserInfo Exists - Will Update");
        return [self updateUserInfoWithData:dict];
    }
    else
    {
        MOOCDatabaseUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"MOOCDatabaseUser" inManagedObjectContext:context];
        if (user)
        {
            for (NSString *obj in dict)
            {
                if (![obj isEqualToString:@"success"])
                {
                    NSString *value = [dict objectForKey:obj];
                    if (value)
                        [user setValue:value forKey:obj];
                }
            }
            user.last_update = [NSDate date];
            NSError *err = nil;
            [lock lock];
            BOOL isSuccess = [context save:&err];
            [lock unlock];
            
            if (isSuccess) return YES;
            else
            {
                NSLog(@"Error When Creating UserInfo - %@", [err localizedDescription]);
                return NO;
            }
        }
        else
        {
            NSLog(@"Fatal Error: Fail to creating MOOCDatabaseUser object");
            return NO;
        }
    }
}

- (NSArray *)getCourseData
{
    NSArray *arr = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:nil];
    if (!arr || ![arr count]) return nil;
    else
    {
        NSMutableArray *retArr = [[NSMutableArray alloc] init];
        for (MOOCDatabaseCourse *course in arr)
        {
            NSArray *keys = [[[course entity] attributesByName] allKeys];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self deleteUselessDict:[course dictionaryWithValuesForKeys:keys]]];
            [dict removeObjectForKey:@"sections"];
            [retArr addObject:dict];
        }
        return retArr;
    }
}

- (NSDictionary *)getCourseData:(NSString *)cid withSections:(BOOL)section
{
    NSString *predStr = [NSString stringWithFormat:@"course_id like '%@'", cid];
    NSArray *courses = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:[NSPredicate predicateWithFormat:predStr]];
    if (!courses || ![courses count]) return nil;
    else if ([courses count]==1)
    {
        MOOCDatabaseCourse *course = courses[0];
        NSArray *keys = [[[course entity] attributesByName] allKeys];
        NSMutableDictionary *target = [NSMutableDictionary dictionaryWithDictionary:[self deleteUselessDict:[course dictionaryWithValuesForKeys:keys]]];
        if (section && ![[target objectForKey:@"sections"] isEmpty])
        {
            [target setObject:@"1" forKey:@"sections"];
        }
        return target;
    }
    else
    {
        NSLog(@"Error: Duplicate Course %@ Exist - Delete All", cid);
        [self deleteCourse:cid];
        return nil;
    }
}

- (NSDictionary *)getUserInfo
{
    NSArray *users = [self getDataInTable:@"MOOCDatabaseUser" Predicate:nil];
    if (!users || ![users count]) return nil;
    else if ([users count] == 1)
    {
        MOOCDatabaseCourse *user = users[0];
        NSArray *keys = [[[user entity] attributesByName] allKeys];
        return [self deleteUselessDict:[user dictionaryWithValuesForKeys:keys]];
    }
    else
    {
        NSLog(@"Error: Duplicate Users Exist - Delete All");
        [self deleteUserInfo];
        return nil;
    }
}

- (BOOL)updateCourse:(NSString *)cid withData:(NSDictionary *)idict
{
    NSDictionary *dict = [self deleteUselessDict:idict];
    NSString *predStr = [NSString stringWithFormat:@"course_id like '%@'", cid];
    NSArray *courses = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:[NSPredicate predicateWithFormat:predStr]];
    if (!courses || ![courses count])
    {
        NSLog(@"No Course %@ Found - Will Create It",cid);
        NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithDictionary:idict];
        [sendDict setObject:cid forKey:sMOOCCourseID];
        return [self insertCourseWithData:sendDict];
    }
    else if ([courses count]==1)
    {
        MOOCDatabaseCourse *course = courses[0];
        for (NSString *obj in dict)
            if (![obj isEqualToString:sMOOCCourseID]&&![obj isEqualToString:@"active"]&&![obj isEqualToString:@"advertised_start"]&&![obj isEqualToString:@"status"]&&![obj isEqualToString:@"error"])
            {
                NSString *valuenew = [dict objectForKey:obj];
                NSString *valueold = [course valueForKey:obj];
                if (![valueold isEqual:valuenew])
                {
                    //NSLog(@"%@:%@->%@",obj,valueold,valuenew);
                    if ([obj isEqualToString:@"enrollment_date"] || [obj isEqualToString:@"enrollment_start"] || [obj isEqualToString:@"enrollment_end"] || [obj isEqualToString:@"course_start"] || [obj isEqualToString:@"course_end"])
                    {
                        NSDate *date = [format dateFromString:valuenew];
                        if (date)
                            [course setValue:date forKey:obj];
                    }
                    else if ([obj isEqualToString:@"is_full"] || [obj isEqualToString:@"registered"])
                    {
                        [course setValue:[NSNumber numberWithBool:[valuenew boolValue]] forKey:obj];
                    }
                    else
                    {
                        [course setValue:valuenew forKey:obj];
                    }
                }
            }
        course.last_update = [NSDate date];
        NSError *err = nil;
        [lock lock];
        BOOL isSuccess = [context save:&err];
        [lock unlock];
        if (isSuccess)
        {
            NSLog(@"Update Course %@ Completed.",cid);
            return YES;
        }
        else
        {
            NSLog(@"Error When Updating Course %@ - %@", cid, [err localizedDescription]);
            return NO;
        }
    }
    else
    {
        NSLog(@"Error: Duplicate Course %@ Exist - Delete All", cid);
        [self deleteCourse:cid];
        return NO;
    }
}

- (BOOL)updateUserInfoWithData:(NSDictionary *)idict
{
    NSDictionary *dict = [self deleteUselessDict:idict];
    NSArray *users = [self getDataInTable:@"MOOCDatabaseUser" Predicate:nil];
    if (!users || ![users count])
    {
        NSLog(@"No UserInfo Found - Create it");
        return [self insertUserInfoWithData:idict];
    }
    else if ([users count]==1)
    {
        MOOCDatabaseCourse *user = users[0];
        for (NSString *obj in dict)
        {
            if (![obj isEqualToString:@"success"])
            {
                NSString *valuenew = [dict objectForKey:obj];
                NSString *valueold = [user valueForKey:obj];
               // NSLog(@"%@:%@->%@",obj,valueold,valuenew);
                if (valueold && valueold!=valuenew)
                    [user setValue:valuenew forKey:obj];
            }
        }
        user.last_update = [NSDate date];
        NSError *err = nil;
        [lock lock];
        BOOL isSuccess = [context save:&err];
        [lock unlock];
        if (isSuccess) return YES;
        else
        {
            NSLog(@"Error When Updating UserInfo - %@", [err localizedDescription]);
            return NO;
        }
    }
    else
    {
        NSLog(@"Error: Duplicate Users Exist - Delete All");
        [self deleteUserInfo];
        return NO;
    }
}

- (BOOL)deleteCourse:(NSString *)cid
{
    NSArray *courses;
    if (cid)
    {
         courses = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:[NSPredicate predicateWithFormat:@"course_id like *%@*", cid]];
    }
    else
    {
        courses = [self getDataInTable:@"MOOCDatabaseCourse" Predicate:nil];
    }
   
    NSError *err = nil;
    if (!courses||![courses count]) return NO;
    for (NSManagedObject *obj in courses)
        [context deleteObject:obj];
    [lock lock];
    BOOL isSuccess = [context save:&err];
    [lock unlock];
    
    if (!isSuccess)
    {
        NSLog(@"Error When Deleting Course %@ - %@", cid, [err localizedDescription]);
        return NO;
    }
    else return YES;
}

- (BOOL)deleteUserInfo
{
    NSArray *users = [self getDataInTable:@"MOOCDatabaseUser" Predicate:nil];
    if (!users||![users count]) return NO;
    for (NSManagedObject *obj in users)
        [context deleteObject:obj];
    NSError *err = nil;
    BOOL isSuccess = [context save:&err];
    if (!isSuccess)
    {
        NSLog(@"Error When Deleting UserInfo - %@", [err localizedDescription]);
        return NO;
    }
    else return YES;
}

- (NSArray *)getDataInTable:(NSString *)table Predicate:(NSPredicate *)predicate
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    if (predicate) [req setPredicate:predicate];
    NSError *err = nil;
    NSArray *arr;
    [lock lock];
    arr = [context executeFetchRequest:req error:&err];
    [lock unlock];
    if (err)
    {
        NSLog(@"Error When Fetching Data From %@ %@ - %@", table, [NSString stringWithFormat:@"%@",predicate], [err localizedDescription]);
        return nil;
    }
    else if (![arr count])
    {
        NSLog(@"Error When Fetching Data From %@ %@ - Target Not Exist", table, [NSString stringWithFormat:@"%@",predicate]);
        return nil;
    }
    else return arr;
}

- (NSDictionary *)deleteUselessDict:(NSDictionary *)dict
{
    NSMutableDictionary *dictNew = [[NSMutableDictionary alloc] init];
    for (NSString *key in dict)
    {
        id value = [dict objectForKey:key];
        if (value&&![value isKindOfClass:[NSNull class]])
        {
            if ([value respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)])
            {
                NSString *valueWithoutSpace = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (![valueWithoutSpace isEqualToString:@""])
                    [dictNew setObject:value forKey:key];
            }
            else
            {
                [dictNew setObject:value forKey:key];
            }
            
        }
    }
    return [NSDictionary dictionaryWithDictionary:dictNew];
}

- (BOOL)checkValid
{
    //NSLog(@"%@",[save objectForKey:sMOOCIsValid]);
    BOOL isValid = [[save objectForKey:sMOOCIsValid] boolValue];
    NSDate *date = [save objectForKey:sMOOCIsValidDate];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (isValid&&date&&interval<iMOOCValidTime)
    {
        return YES;
    }
    else
    {
        int inValid = 0;
        NSArray *arr = [[MOOCCourseData sharedInstance] getCourseData];
        for (NSDictionary *dict in arr)
        {
            inValid++;
            NSDate *date = [dict objectForKey:sMOOCDatebaseIsValid];
            NSTimeInterval interval = [date timeIntervalSinceNow];
            if (interval<iMOOCValidTime) inValid--;
        }
        if (!inValid)
            [save setObject:@"1" forKey:sMOOCIsValid];
        else
            [save setObject:@"0" forKey:sMOOCIsValid];
        [save setObject:[NSDate date] forKey:sMOOCIsValidDate];
        [save synchronize];
        if (!inValid) return YES;
    }
    return NO;
}

- (BOOL)checkValid:(NSString *)cid
{
    NSDictionary *dict = [[MOOCCourseData sharedInstance] getCourseData:cid withSections:NO];
    NSDate *date = [dict objectForKey:sMOOCDatebaseIsValid];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    if (interval<iMOOCValidTime) return YES;
    return NO;
}

@end
