//
//  DiroutDealViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "DiroutDealViewController.h"
#import "UIView+Toast.h"
#import "StringUtil.h"
#import "OrderTableViewCell.h"
#import "DiroutDealDetailViewController.h"

@interface DiroutDealViewController ()

@end

@implementation DiroutDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"直入直出办理";
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
    if([SCOrderIn isExistInTable]){
        NSString *criteria;
        NSArray *array;
        if([StringUtil scString:order] && [StringUtil scString:suppliername]){
            criteria = [NSString stringWithFormat:@" WHERE number = '%@' and supplier = '%@' and isDirout = 0 and isFinish = 0 ",order,suppliername];
            array = [SCOrderIn findByCriteria:criteria];
        }else if(![StringUtil scString:order] && ![StringUtil scString:suppliername]){
            array = [SCOrderIn findByCriteria:@" WHERE isDirout = 0 and isFinish = 0 "];
        }else{
            if([StringUtil scString:order]){
                criteria = [NSString stringWithFormat:@" WHERE number = '%@' and isDirout = 0 and isFinish = 0 ",order];
            }else if([StringUtil scString:suppliername]){
                criteria = [NSString stringWithFormat:@" WHERE supplier = '%@' and isDirout = 0 and isFinish = 0 ",suppliername];
            }
            array = [SCOrderIn findByCriteria:criteria];
        }
        
        if(array.count>0){
            //重新加载数据
            self.inArray = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
        }else{
            [self.view makeToast:@"暂无数据,请返回主页同步入库订单" duration:3.0 position:CSToastPositionCenter];
        }
        
    }else{
        [SCOrderIn createTable];
        [self.view makeToast:@"暂无数据,请返回主页同步入库订单" duration:3.0 position:CSToastPositionCenter];
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
        DiroutDealDetailViewController *viewController = segue.destinationViewController;
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
    SCOrderIn *order = self.inArray[indexPath.row];
    [cell showCell:order];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //单击item,跳转到该订单详情
    selOrder = self.inArray[indexPath.row];
    [self performSegueWithIdentifier:@"orderdirouttodetail" sender:self];
}

@end
