//
//  ConfirmDiroutViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCOrderIn.h"
#import "SCOrderInMat.h"
#import "OrderDetailTableViewCell.h"
#import "DateTool.h"
#import "StringUtil.h"
#import "SCDirout.h"
#import "InConsumer.h"
#import "DiroutDealViewController.h"
#import "ChooseConsumerViewController.h"
#import "UartLib.h"

@interface ConfirmDiroutViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PassConsumerDelegate,UartDelegate>

@property (nonatomic, strong) InConsumer *consumer;//领料商
@property (nonatomic, strong) SCOrderIn *order;
@property (nonatomic, strong) NSMutableArray *selArray;//保存已选中材料的数组
@property (nonatomic, strong) NSMutableArray *unSelArray;//保存未选择的材料的数组
@property (nonatomic, strong) NSMutableArray *array;//直入直出单

@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *consumerLabel;


@end
