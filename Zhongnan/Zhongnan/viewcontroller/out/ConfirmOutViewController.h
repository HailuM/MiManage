//
//  ConfirmOutViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutDealViewController.h"
#import "ChooseConsumerViewController.h"
#import "UartLib.h"
//#import "MBProgressHUD.h"

@interface ConfirmOutViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PassConsumerDelegate,UartDelegate,UIAlertViewDelegate>{
    int hasPaper;//0,正常  1,缺纸
}

@property (nonatomic, strong) PuOrder *order;
@property (nonatomic, strong) NSMutableArray *selArray;//保存已选中材料的数组
@property (nonatomic, strong) NSMutableArray *unSelArray;//保存未选择的材料的数组
@property (nonatomic, strong) Consumer *consumer;//领料商

@property (nonatomic, strong) NSMutableArray *array;//出库单


@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *consumerLabel;

@end
