//
//  InDealViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "InDealViewController.h"
#import "UIView+Toast.h"
#import "StringUtil.h"
#import "OrderTableViewCell.h"
#import "InDealDetailViewController.h"

@interface InDealViewController ()

@end

@implementation InDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"入库办理";
    //注册键盘消失事件
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];

    
    if(!self.inArray){
        self.inArray = [[NSArray alloc] init];
    }
    
    
    orderid = self.etOrder.text;
    supplier = self.etSupplier.text;
    [self initDataWithOrder:orderid supplier:supplier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//输入框监听事件
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.etOrder resignFirstResponder];
    [self.etSupplier resignFirstResponder];
}

/**
 *  数据库读取数据
 */
-(void)initDataWithOrder:(NSString *)order supplier:(NSString *)suppliername{
    if([PuOrder isExistInTable]){
        NSString *criteria;
        NSArray *array;
        if(order.length==0){
            order = @"";
        }
        if(suppliername.length==0){
            suppliername = @"";
        }
        criteria = [NSString stringWithFormat:@" WHERE type = 'rk' and isFinish = 0 and number like '%%%@%%' and supplier like '%%%@%%'",order,suppliername];
        
        array = [PuOrder findByCriteria:criteria];
        
        if(array.count>0){
            //重新加载数据
            self.inArray = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
        }else{
            [self.view makeToast:@"没有相关订单信息" duration:3.0 position:CSToastPositionCenter];
            //搜索框置空
            self.etOrder.text = @"";
            self.etSupplier.text = @"";
        }
        
    }else{
        [PuOrder createTable];
        [self.view makeToast:@"没有相关订单信息" duration:3.0 position:CSToastPositionCenter];
        //搜索框置空
        self.etOrder.text = @"";
        self.etSupplier.text = @"";
    }
}

/**
 *  过滤订单号
 *
 *  @param sender <#sender description#>
 */
- (IBAction)searchByOrder:(id)sender {
    orderid = self.etOrder.text;
    supplier = self.etSupplier.text;
    [self initDataWithOrder:orderid supplier:supplier];
}

/**
 *  过滤供应商
 *
 *  @param sender <#sender description#>
 */
- (IBAction)searchBySupplier:(id)sender {
    orderid = self.etOrder.text;
    supplier = self.etSupplier.text;
    [self initDataWithOrder:orderid supplier:supplier];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *identifier = segue.identifier;
    if([identifier isEqualToString:@"orderintodetail"]){
        InDealDetailViewController *viewController = segue.destinationViewController;
        viewController.order = selOrder;
    }
    
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *cell = [OrderTableViewCell cellWithTableView:tableView];
    PuOrder *order = self.inArray[indexPath.row];
    [cell showCell:order];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //单击item,跳转到该订单详情
    selOrder = self.inArray[indexPath.row];
    [self performSegueWithIdentifier:@"orderintodetail" sender:self];
}

@end
