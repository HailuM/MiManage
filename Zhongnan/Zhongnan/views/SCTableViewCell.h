//
//  SCTableViewCell.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/30.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTableViewCell : UITableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView;
-(void)showCell:(id)value;

@end
