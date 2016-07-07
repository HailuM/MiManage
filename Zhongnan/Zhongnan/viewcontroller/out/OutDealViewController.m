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
    if([SCOrderOut isExistInTable]){
        NSString *criteria;
        NSArray *array;
        if([StringUtil scString:order]){
            criteria = [NSString stringWithFormat:@" WHERE number = '%@' and isFinish = 0 ",order];
            array = [SCOrderOut findByCriteria:criteria];
        }else {
            array = [SCOrderOut findAll];
        }
        if(array.count>0){
            //重新加载数据
            self.outArray = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
        }else{
            [self.view makeToast:@"暂无数据,请返回主页同步出库订单" duration:3.0 position:CSToastPositionCenter];
        }
        
    }else{
        [SCOrderOut createTable];
        [self.view makeToast:@"暂无数据,请返回主页同步出库订单" duration:3.0 position:CSToastPositionCenter];
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
    SCOrderIn *order = self.outArray[indexPath.row];
    [cell showCell:order];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //单击item,跳转到该订单详情
    selOrder = self.outArray[indexPath.row];
    [self performSegueWithIdentifier:@"orderouttodetail" sender:self];
}

@end
