//
//  InBillChild.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/** 
 * 上传入库单子表明细
 */
@interface InBillChild : JKDBModel
/** 入库单行ID    UUID生成*/
@property(nonatomic,copy)NSString *wareentryid;
/** 入库单行的数量*/
@property(nonatomic,copy)NSString *qty;
/** 生成的入库单主表ID  我使用的是UUID*/
@property(nonatomic,copy)NSString *receiveid;
/** 来源订单表体ID*/
@property(nonatomic,copy)NSString *orderEntryid;
/** 制单时间  格式 yyyy-mm-dd hh:mm:ss*/
@property(nonatomic,copy)NSString *preparertime;
/** 来源订单表头ID*/
@property(nonatomic,copy)NSString *orderid;

@property(nonatomic,assign) int xsxh;//排序

@end
