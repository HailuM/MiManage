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

@interface PrintViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UartDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
