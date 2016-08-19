//
//  PrintViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/19.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UartLib.h"
#import "StringUtil.h"
#import "UIView+Toast.h"

@interface PrintViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UartDelegate> {
    BOOL isSearch;//是否正在搜索蓝牙
    int hasPaper;//0,正常  1,缺纸
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UartLib *uartLib;
@property (strong, nonatomic) CBPeripheral *connectPeripheral;

@end
