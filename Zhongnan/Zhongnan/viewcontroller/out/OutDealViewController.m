//
//  OutDealViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "OutDealViewController.h"
#import "UIView+Toast.h"
#import "StringUtil.h"
#import "OrderTableViewCell.h"
#import "OutDealDetailViewController.h"

@interface OutDealViewController ()

@end

@implementation OutDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"出库办理";
    //注册键盘消失事件
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    if(!self.outArray){
        self.outArray = [[NSArray alloc] init];
    }
    orderid = self.etOrder.text;
    [self initDataWithOrder:orderid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//输入框监听事件
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.etOrder resignFirstResponder];
}

/**
 *  数据库读取数据
 */
-(void)initDataWithOrder:(NSString *)order{
    if([PuOrder isExistInTable]){
        NSString *criteria1;
        NSArray *array1;
        if(order.length==0){
            order = @"";
        }
        criteria1 = [NSString stringWithFormat:@" WHERE type = 'ck' and isFinish = 0 and number like '%%%@%%'",order];
        //出库来源,1同步出库,2同步入库,做完入库生成的出库任务
        array1 = [PuOrder findByCriteria:criteria1];
        
        NSString *criteria2;
        NSArray *array2;
        if(order.length==0){
            order = @"";
        }
        criteria2 = [NSString stringWithFormat:@" WHERE type = 'rkck' and isFinish = 0 and number like '%%%@%%'",order];
        //出库来源,1同步出库,2同步入库,做完入库生成的出库任务
        array2 = [PuOrder findByCriteria:criteria2];
        
        
        if(array1.count>0||array2.count>0){
            //重新加载数据
            self.outArray = [[NSMutableArray alloc] init];
            if(array1.count>0){
                [self.outArray addObjectsFromArray:array1];
            }
            if(array2.count>0){
                [self.outArray addObjectsFromArray:array2];
            }
            [self.tableView reloadData];
        }else{
            [self.view makeToast:@"没有相关订单信息" duration:3.0 position:CSToastPositionCenter];
            //搜索框置空
            self.etOrder.text = @"";
        }
        
    }else{
        [PuOrder createTable];
        [self.view makeToast:@"没有相关订单信息" duration:3.0 position:CSToastPositionCenter];
        //搜索框置空
        self.etOrder.text = @"";
    }
}

/**
 *  过滤订单号
 *
 *  @param sender <#sender description#>
 */
- (IBAction)searchByOrder:(id)sender {
    orderid = self.etOrder.text;
    [self initDataWithOrder:orderid];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *identifier = segue.identifier;
    if([identifier isEqualToString:@"orderouttodetail"]){
        OutDealDetailViewController *viewController = segue.destinationViewController;
        viewController.order = selOrder;
    }
}


#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.outArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *cell = [OrderTableViewCell cellWithTableView:tableView];
    PuOrder *order = self.outArray[indexPath.row];
    [cell showCell:order];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //单击item,跳转到该订单详情
    selOrder = self.outArray[indexPath.row];
    [self performSegueWithIdentifier:@"orderouttodetail" sender:self];
}

@end
