//
//  UUIDUtil.m
//  Portal
//
//  Created by Emi-iMac on 15/4/9.
//  Copyright (c) 2015年 emi365. All rights reserved.
//

#import "UUIDUtil.h"

@implementation UUIDUtil

+(NSString *)getUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

@end
