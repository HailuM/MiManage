//
//  InDealViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

/**
 *  入库处理
 */
@interface InDealViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSString *orderid;//订单号
    NSString *supplier;//供应商
    
    PuOrder *selOrder;
}

@property (nonatomic, strong) NSArray *inArray;

@property (weak, nonatomic) IBOutlet UITextField *etOrder;
@property (weak, nonatomic) IBOutlet UITextField *etSupplier;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
