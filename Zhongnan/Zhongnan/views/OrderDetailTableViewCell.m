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
    sourceQty = inMat.sourceQty-inMat.rkQty;//未处理入库数量
    qty = inMat.curQty;//当前已处理数量
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
