//
//  SCIn.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 *  入库单 上传用
 * {
     "preparertime": "制单时间",
     "receiveid": "入库单id",
     "orderid": "订单id",
     "orderEntryid": "订单entryid，来源于下载订单对应的物料信息接口的返回值entryid ",
     "qty": "入库数量"
 }
 */

@interface SCIn : JKDBModel

@property (nonatomic, copy) NSDate *preparetime;
@property (nonatomic, copy) NSString *receiveid;
@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *orderEntryid;
@property (nonatomic, assign) double qty;

@end
