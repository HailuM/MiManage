//
//  OutDealDetailViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuOrder.h"
#import "Consumer.h"
#import "OrderDetailTableViewCell.h"
#import "ConfirmOutViewController.h"
#import "UIView+Toast.h"
#import "ChooseConsumerViewController.h"

@interface OutDealDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PassConsumerDelegate>{
    NSMutableArray *selArray;//保存已选中材料的数组
    
    NSMutableArray *unSelArray;//保存未选择的材料的数组
    
    NSArray *matArray;//数据库查询出来的材料数组
}
@property (nonatomic, strong) PuOrder *order;
@property (nonatomic, strong) Consumer *consumer;//领料商



@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *supplierLabel;
@property (strong, nonatomic) IBOutlet UILabel *addrLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;
@property (strong, nonatomic) IBOutlet UILabel *checkLabel;
@property (strong, nonatomic) IBOutlet UILabel *checkedNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *consumerLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@end
