//
//  DiroutDealDetailViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCOrderIn.h"
#import "SCOrderInMat.h"
#import "OrderDetailTableViewCell.h"
#import "ConfirmDiroutViewController.h"
#import "ChooseConsumerViewController.h"

@interface DiroutDealDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PassConsumerDelegate>{
    
    NSMutableArray *selArray;//保存已选中材料的数组
    
    NSMutableArray *unSelArray;//保存未选择的材料的数组
    
    NSArray *matArray;//数据库查询出来的材料数组
    
}

@property (nonatomic, strong) OutConsumer *consumer;//领料商
@property (nonatomic, strong) SCOrderIn *order;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;
@property (strong, nonatomic) IBOutlet UILabel *checkLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *consumerLabel;//领料商

@end
