//
//  DiroutDealViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
/**
 *  直入直出处理
 */
@interface DiroutDealViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSString *orderid;//订单号
    NSString *supplier;//供应商
    
    SCOrderIn *selOrder;
}
@property (nonatomic, strong) NSArray *inArray;

@property (weak, nonatomic) IBOutlet UITextField *etOrder;
@property (weak, nonatomic) IBOutlet UITextField *etSupplier;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
