//
//  OutDealViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface OutDealViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSString *orderid;//订单号
    NSString *supplier;//供应商
    
    SCOrderOut *selOrder;
}

@property (nonatomic, strong) NSArray *outArray;

@property (weak, nonatomic) IBOutlet UITextField *etOrder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
