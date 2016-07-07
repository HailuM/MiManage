//
//  ChooseSupplierViewController.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InConsumer.h"
#import "OutConsumer.h"



@protocol PassConsumerDelegate
-(void)pass:(id)value;

@end

@interface ChooseConsumerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign)  int flag;//0 出库   1 直入直出
@property (nonatomic, copy) NSString *orderid;//订单di
@property(assign,nonatomic)id<PassConsumerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *consumerArray;
@end
