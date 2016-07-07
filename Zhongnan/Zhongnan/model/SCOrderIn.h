//
//  SCOrder.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 * 订单,入库用
 */

@interface SCOrderIn : JKDBModel

@property (nonatomic, copy) NSString *id;//订单id
@property (nonatomic, copy) NSString *number;//订单号
@property (nonatomic, copy) NSString *date;//订单制单时间
@property (nonatomic, copy) NSString *supplier;//供应商
@property (nonatomic, copy) NSString *materialDesc;//材料描述
@property (nonatomic, copy) NSString *Addr;//地址楼栋
@property (nonatomic, copy) NSString *ProjectName;//项目名称
@property (nonatomic, copy) NSString *Company;//公司

@property (nonatomic, assign) int isDirout;//1,直入直出  0,非直入直出
@property (nonatomic, assign) int isFinish;//0,未结束    1,已结束
// TODO 收货联系人 未知

//@property (nonatomic, assign) int inOrOut;//0,出库  1,入库
//
//@property (nonatomic, copy) NSString *cktokenStr;//出库token
//@property (nonatomic, copy) NSString *rktokenStr;//入库token
@end
