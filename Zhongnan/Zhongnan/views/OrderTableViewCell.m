//
//  OrderTableViewCell.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "OrderTableViewCell.h"


@implementation OrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"OrderTableViewCell";
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderTableViewCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

-(void)showCell:(id)value{
    if(self.flag==0){
        PuOrder *order = (PuOrder *)value;
        number = order.number;
        time = order.date;
        supplier = order.supplier;
        materiaDesc = order.materialDesc;
        addr = order.Addr;
        
        
    }else if(self.flag==1){
        if([value isKindOfClass:[OutBill class]]){
            OutBill *outBill = value;
            number = outBill.deliverNo;
            time = outBill.preparertime;
            supplier = outBill.supplier;
            materiaDesc = outBill.materialDesc;
            addr = outBill.Addr;
        }
        if([value isKindOfClass:[DirBill class]]){
            DirBill *dirBill = value;
            number = dirBill.number;
            time = dirBill.preparertime;
            supplier = dirBill.supplier;
            materiaDesc = dirBill.materialDesc;
            addr = dirBill.Addr;
        }
        
    }
    self.numberLabel.text = number;
    self.timeLabel.text = time;
    self.supplierLabel.text = supplier;
    self.materialLabel.text = materiaDesc;
    self.addrLabel.text = addr;
}

@end
