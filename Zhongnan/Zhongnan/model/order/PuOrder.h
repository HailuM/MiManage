//
//  PuOrder.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 * {
 * "tokenStr": "3958f542-c88e-4de0-9327-6f1b510bd6b4",
 * "details": [
 * {
 * "id": "441F5FBA-5978-4DFF-8859-18AA70886300",
 * "number": "201606020004_002",
 * "date": "2016/06/02",
 * "supplier": "",
 * "materialDesc": "大理石4,",
 * "Addr": "城山路83号"
 * }
 * ]
 * }
 */
@interface PuOrder : JKDBModel

@property(nonatomic,copy) NSString *id;//主表id
@property(nonatomic,copy) NSString *sourceid;//手机生成的出库单,来源是手机下载的入库单的id
@property(nonatomic,copy) NSString *OrderId;//下载出库任务单id
@property(nonatomic,copy) NSString *number;
@property(nonatomic,copy) NSString *supplier;
@property(nonatomic,copy) NSString *materialDesc;
@property(nonatomic,copy) NSString *Addr;
@property(nonatomic,copy) NSString *type;  //"rkck":手机上的入库之后做的出库  "zrzc":直入直出  "rk":入库  "ck":出库
@property(nonatomic,assign) BOOL zcwc;//是否直出完成
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *ProjectName;
@property(nonatomic,copy) NSString *Company;
@property(nonatomic,copy) NSString *time;//存在数据库的修改或者new的时间

@property(nonatomic,copy) NSString *date;//从服务器下载的订单的Date,用来显示订单时间

@property(nonatomic,assign)int isFinish;//0,未完成;1,已完成
@end
