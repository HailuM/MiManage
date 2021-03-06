//
//  SCDBTool.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "InConsumer.h"
//#import "OutConsumer.h"
//#import "SCIn.h"
//#import "SCOrderIn.h"
//#import "SCOrderInMat.h"
//#import "SCOut.h"
//#import "SCDirout.h"
//#import "SCOrderOut.h"
//#import "SCOrderOutMat.h"
//#import "SCOrderMOut.h"
//#import "SCOrderMDirout.h"
#import "User.h"
#import "Consumer.h"
#import "PuOrder.h"
#import "PuOrderChild.h"
#import "InBill.h"
#import "InBillChild.h"
#import "OutBill.h"
#import "OutBillChild.h"
#import "DirBill.h"
#import "DirBillChild.h"

@interface SCDBTool : NSObject


/**
 *  将jsonString转为NSDictionary
 *
 *  @param string <#string description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)dictionaryWithJSONString:(NSString *)string;


/**
 *  将jsonstring转为NSArray
 *
 *  @param string <#string description#>
 *
 *  @return <#return value description#>
 */
+(NSArray *)arrayWithJSONString:(NSString *)string;

/**
 *  将NSArray或者NSDictionary转成JSON对象toString
 *
 *  @param object <#object description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)stringWithData:(id)object;

/**
 *  删除入库单和直入直出单相关数据
 *
 *  @return
 */
+(BOOL)clearInData:(NSString *)rkToken;

/**
 *  删除出库单及相关数据
 *
 *  @return <#return value description#>
 */
+(BOOL)clearOutData:(NSString *)ckToken;



/**
 *  清除所有数据.除了user表
 */
+(BOOL)clearAllData;

@end
