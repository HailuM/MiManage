//
//  OrderTableViewCell.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SCTableViewCell.h"
#import "PuOrder.h"
#import "OutBill.h"
#import "DirBill.h"

@interface OrderTableViewCell : SCTableViewCell {
    NSString *number;//订单号
    NSString *time;//时间
    NSString *supplier;//供方
    NSString *materiaDesc;//材料
    NSString *addr;//楼栋,地址
    
}
@property(nonatomic,assign) NSInteger flag; //0,表示是订单显示  1,表示是打印显示


@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *materialLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;

@end
