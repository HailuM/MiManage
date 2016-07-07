//
//  SCOrderOut.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"
/**
 *  出库订单
 */
@interface SCOrderOut : JKDBModel
@property (nonatomic, copy) NSString *id;//订单id
@property (nonatomic, copy) NSString *number;//订单号
@property (nonatomic, copy) NSString *date;//订单制单时间
@property (nonatomic, copy) NSString *supplier;//供应商
@property (nonatomic, copy) NSString *materialDesc;//材料描述
@property (nonatomic, copy) NSString *Addr;//地址楼栋
@property (nonatomic, copy) NSString *ProjectName;//项目名称
@property (nonatomic, copy) NSString *Company;//公司
@property (nonatomic, copy) NSString *OrderId;//

@property (nonatomic, assign) int isFinish;//0,未结束    1,已结束
// TODO 收货联系人 未知
@end
