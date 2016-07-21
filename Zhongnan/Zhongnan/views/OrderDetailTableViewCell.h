//
//  OrderDetailTableViewCell.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SCTableViewCell.h"
#import "PuOrderChild.h"
#import "StringUtil.h"

@interface OrderDetailTableViewCell : SCTableViewCell {
    NSString *name;//材料名称
    NSString *model;//规格型号
    double sourceQty;//未处理数量
    double qty;//此次处理数量
    NSString *unit;//单位
    NSString *brand;//品牌
    NSString *note;//备注
}

@property (nonatomic,copy) NSString *orderType;//单据类型,判断是出库,入库,入库出库

@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UILabel *matNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *modelLabel;
@property (strong, nonatomic) IBOutlet UILabel *sourceQtyLabel;
@property (strong, nonatomic) IBOutlet UILabel *unitLabel;
@property (strong, nonatomic) IBOutlet UILabel *brandLabel;
@property (strong, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *delLabel;
@property (weak, nonatomic) IBOutlet UIButton *addLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;

@end
