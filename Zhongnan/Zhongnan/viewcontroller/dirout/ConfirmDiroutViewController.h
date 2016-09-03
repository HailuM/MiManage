//
//  ConfirmDiroutViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailTableViewCell.h"
#import "DateTool.h"
#import "StringUtil.h"
#import "Consumer.h"
#import "DiroutDealViewController.h"
#import "ChooseConsumerViewController.h"
#import "UartLib.h"
#import "InDealDetailViewController.h"

@protocol DiroutDelegate <NSObject>

-(void)pass:(NSArray *)array;

@end

@interface ConfirmDiroutViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PassConsumerDelegate,UartDelegate>{
    int hasPaper;//0,正常  1,缺纸
}
@property (nonatomic, strong) Consumer *consumer;//领料商
@property (nonatomic, strong) PuOrder *order;
@property (nonatomic, strong) NSMutableArray *selArray;//保存已选中材料的数组
@property (nonatomic, strong) NSMutableArray *unSelArray;//保存未选择的材料的数组
@property (nonatomic, strong) NSMutableArray *array;//直入直出单

@property (nonatomic,strong) NSMutableArray *finishArray;//存放已完成的材料



@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *consumerLabel;


@property (nonatomic, assign) id<DiroutDelegate> delegate;

@end
