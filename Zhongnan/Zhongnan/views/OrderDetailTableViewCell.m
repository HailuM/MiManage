//
//  OrderDetailTableViewCell.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "OrderDetailTableViewCell.h"

@implementation OrderDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"OrderDetailTableViewCell";
    OrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailTableViewCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

-(void)showCell:(id)value {

    PuOrderChild *inMat = (PuOrderChild *)value;
    name = inMat.Name;
    model = inMat.model;//规格型号
    
    if([_orderType isEqualToString:@"rk"]){
        sourceQty = [inMat.sourceQty doubleValue]-[inMat.rkQty doubleValue]-[inMat.curQty doubleValue];//未处理入库数量
        
    }else if([_orderType isEqualToString:@"ck"]){
        sourceQty = [inMat.sourceQty doubleValue]-[inMat.ckQty doubleValue]-[inMat.curQty doubleValue];//未处理出库数量
        
    }else if([_orderType isEqualToString:@"rkck"]){
        sourceQty = [inMat.sourceQty doubleValue]-[inMat.ckQty doubleValue]-[inMat.curQty doubleValue];//未处理出库数量
        
    }else if ([_orderType isEqualToString:@"zrzc"]){
        sourceQty = [inMat.sourceQty doubleValue]-[inMat.rkQty doubleValue]-[inMat.curQty doubleValue];//未处理入库数量
    }
    
    
    
    qty = [inMat.curQty doubleValue];//当前已处理数量  默认为单据剩余的数量
    unit = inMat.unit;//单位
    brand = inMat.brand;//品牌
    note = inMat.note;//备注
    
    
    self.matNameLabel.text = name;
    self.qtyLabel.text = [StringUtil changeFloat:[NSString stringWithFormat:@"%f",qty]];
    self.modelLabel.text = model;
    self.sourceQtyLabel.text = [StringUtil changeFloat:[NSString stringWithFormat:@"%f",sourceQty]];
    self.unitLabel.text = unit;
    self.brandLabel.text = brand;
    self.noteLabel.text = note;
}


@end
