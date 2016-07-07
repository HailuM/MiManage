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
    if([value isKindOfClass:[SCOrderIn class]]){
        SCOrderIn *order = (SCOrderIn *)value;
        number = order.number;
        time = order.date;
        supplier = order.supplier;
        materiaDesc = order.materialDesc;
        addr = order.Addr;
    }else if([value isKindOfClass:[SCOrderOut class]]){
        SCOrderOut *order = (SCOrderOut *)value;
        number = order.number;
        time = order.date;
        supplier = order.supplier;
        materiaDesc = order.materialDesc;
        addr = order.Addr;
    }
    
    self.numberLabel.text = number;
    self.timeLabel.text = time;
    self.supplierLabel.text = supplier;
    self.materialLabel.text = materiaDesc;
    self.addrLabel.text = addr;
    
}

@end
