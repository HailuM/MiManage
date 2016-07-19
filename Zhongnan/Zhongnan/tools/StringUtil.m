//
//  StringUtil.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "StringUtil.h"
#import "DateTool.h"

@implementation StringUtil

+(BOOL)scString:(NSString *)string {
    if(string==nil){
        return NO;
    }
    if([string isEqualToString:@""]){
        return NO;
    }
    if([string isEqualToString:@" "]){
        return NO;
    }
    return YES;
}

+(NSString *)create:(int)i{
    if(i<10){
        return [NSString stringWithFormat:@"000%d",i];
    }else if (i<100){
        return [NSString stringWithFormat:@"00%d",i];
    }else if (i<1000){
        return [NSString stringWithFormat:@"0%d",i];
    }else if(i<10000){
        return [NSString stringWithFormat:@"%d",i];
    }
    return nil;
}

+(NSString *)generateNo:(NSString *)type {
    NSDate *today = [NSDate date];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger no = [userDefaults integerForKey:[NSString stringWithFormat:@"No_%@",type]];
    no++;
    //获取纳秒
    NSTimeInterval record = [today timeIntervalSince1970]*1000*1000*1000;
    double i = record;
    NSString *nano = [NSString stringWithFormat:@"%.f",i];
    NSString *newNano = [nano substringFromIndex:nano.length-5];
    [userDefaults setInteger:no forKey:[NSString stringWithFormat:@"No_%@",type]];
    [userDefaults synchronize];
    return [NSString stringWithFormat:@"%@-%ld%@",[DateTool dateToString:today],(long)no,newNano];
}


+(NSString *)changeFloat:(NSString *)stringFloat
{
    const char *floatChars = [stringFloat UTF8String];
    NSUInteger length = [stringFloat length];
    NSUInteger zeroLength = 0;
    int i = length-1;
    for(; i>=0; i--)
    {
        if(floatChars[i] == '0'/*0x30*/) {
            zeroLength++;
        } else {
            if(floatChars[i] == '.')
                i--;
            break;
        }
    }
    NSString *returnString;
    if(i == -1) {
        returnString = @"0";
    } else {
        returnString = [stringFloat substringToIndex:i+1];
    }
    return returnString;
}

@end
