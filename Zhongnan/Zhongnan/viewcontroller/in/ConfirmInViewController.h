//
//  ConfirmInViewController.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCIn.h"
#import "SCOrderIn.h"
#import "SCOrderInMat.h"
#import "OrderDetailTableViewCell.h"
#import "DateTool.h"
#import "StringUtil.h"
#import "UIView+Toast.h"
#import "InDealViewController.h"
#import "SCOrderMIn.h"
#import "UUIDUtil.h"

@interface ConfirmInViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    SCOrderMIn *mIn;
}

@property (nonatomic, strong) SCOrderIn *order;
@property (nonatomic, strong) NSMutableArray *selArray;//保存已选中材料的数组
@property (nonatomic, strong) NSMutableArray *unSelArray;//保存未选择的材料的数组

@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;

@end
