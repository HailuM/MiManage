//
//  InBill.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 * 上传用的入库单主表
 *
 */

@interface InBill : JKDBModel

@property (nonatomic,copy) NSString *receiveid;//上传用的生成入库单主表id
@property (nonatomic,copy) NSString *orderid;//来源订单表头ID
@property (nonatomic,copy) NSString *number;
@property (nonatomic,copy) NSString *supplier;
@property (nonatomic,copy) NSString *materialDesc;
@property (nonatomic,copy) NSString *Addr;
@property (nonatomic,copy) NSString *ProjectName;
@property (nonatomic,copy) NSString *Company;
@property (nonatomic,copy) NSString *preparertime;//制单时间  格式 yyyy-mm-dd hh:mm:ss
@property (nonatomic,copy) NSString *date;//从服务器下载的订单的Date,用来显示订单时间

@end
