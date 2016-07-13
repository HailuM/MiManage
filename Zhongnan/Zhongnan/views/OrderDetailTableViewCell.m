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
    if([value isKindOfClass:[SCOrderInMat class]]){
        SCOrderInMat *inMat = (SCOrderInMat *)value;
        name = inMat.Name;
        model = inMat.model;//规格型号
        sourceQty = inMat.sourceQty-inMat.hasQty;//未处理数量
        qty = inMat.qty;//已处理数量
        unit = inMat.unit;//单位
        brand = inMat.brand;//品牌
        note = inMat.note;//备注
    }else if([value isKindOfClass:[SCOrderOutMat class]]){
        SCOrderOutMat *outMat = (SCOrderOutMat *)value;
        name = outMat.Name;
        model = outMat.model;//规格型号
        sourceQty = outMat.sourceQty-outMat.hasQty;//未处理数量
        qty = outMat.qty;//已处理数量
        unit = outMat.unit;//单位
        brand = outMat.brand;//品牌
        note = outMat.note;//备注
    }
    
    self.matNameLabel.text = name;
    self.qtyLabel.text = [NSString stringWithFormat:@"%f",qty];
    self.modelLabel.text = model;
    self.sourceQtyLabel.text = [NSString stringWithFormat:@"%f",sourceQty];
    self.unitLabel.text = unit;
    self.brandLabel.text = brand;
    self.noteLabel.text = note;
}


@end
