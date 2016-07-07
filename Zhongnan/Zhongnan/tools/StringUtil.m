//
//  StringUtil.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "StringUtil.h"

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


@end
