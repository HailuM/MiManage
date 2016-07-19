//
//  StringUtil.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject

+(BOOL)scString:(NSString *)string;

+(NSString *)create:(int)i;

//尾数去0
+(NSString *)changeFloat:(NSString *)stringFloat;

/**
 *  根据type生成不同的单据号
 *
 *  @param type SCRK:入库 SCCK:出库 SCZRZC:直入直出
 *
 *  @return 
 */
+(NSString *)generateNo:(NSString *)type;

@end
