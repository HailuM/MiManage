//
//  SCOrderMat.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 *  入库订单上的物料
 *  {
 *  "orderid": "订单id",
 *  "orderentryid": "订单表体id，guid式",
 *  "Name": "物料名称",
 *  "model": "规格型号",
 *  "unit": "单位",
 *  "brand": "品牌",
 *  "note": "备注",
 *  "sourceQty": "未入库数",
 *  "limitQty": "上限数"
 *  }
 */

@interface SCOrderInMat : JKDBModel

@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *orderentryid;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, assign) double sourceQty;
@property (nonatomic, assign) double limitQty;
@property (nonatomic, assign) double qty;//这次处理的数量
@property (nonatomic, assign) double hasQty;//这次处理的数量
@property (nonatomic, assign) double price;

@property (nonatomic, assign) int isFinish;//0,未结束  1,已结束

@end
