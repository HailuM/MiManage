//
//  ConfirmInViewController.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ConfirmInViewController.h"

@interface ConfirmInViewController ()

@end

@implementation ConfirmInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"入库确认";
    
    [self showOrder];
    
    [self.confirmBtn addTarget:self action:@selector(confirmDealIn:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  展示订单信息
 */
-(void)showOrder{
    if(self.order){
        self.numberLabel.text = self.order.number;
        self.supplierLabel.text = self.order.supplier;
        self.addrLabel.text = self.order.Addr;
        // todo
        //        self.contactLabel.text = self.order.con
        if(!self.selArray){
            self.selArray = [[NSMutableArray alloc] init];
        }
        double sum = 0;
        for(SCOrderInMat *inMat in self.selArray){
            sum = sum + inMat.qty;
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu;   总数量:%.2f",(unsigned long)self.selArray.count,sum];
//        [self initData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailTableViewCell *cell = [OrderDetailTableViewCell cellWithTableView:tableView];
    SCOrderInMat *inMat = self.selArray[indexPath.row];
    [cell showCell:inMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    [cell.addBtn addTarget:self action:@selector(delToCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    //减号"-"事件
    cell.delLabel.tag = 2000+indexPath.row;
    [cell.delLabel addTarget:self action:@selector(delQty:) forControlEvents:UIControlEventTouchUpInside];
    
    //加号"+"事件
    cell.addLabel.tag = 3000+indexPath.row;[cell.addLabel addTarget:self action:@selector(addQty:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 2000+indexPath.row;
    SCOrderInMat *inMat = self.selArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    countText.text = [NSString stringWithFormat:@"%f",inMat.qty];
    [alert show];
}

-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    SCOrderInMat *inMat = self.selArray[tag];
    if(inMat.qty-1<=0){
        inMat.qty = 0.0;
    }else{
        inMat.qty = inMat.qty-1;
    }
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    SCOrderInMat *inMat = self.selArray[tag];
    if(inMat.qty+1>inMat.limitQty-inMat.hasQty){
        inMat.qty = inMat.limitQty-inMat.hasQty;
    }else{
        inMat.qty = inMat.qty+1;
    }
    [self.tableView reloadData];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==alertView.firstOtherButtonIndex){
        NSInteger tag = alertView.tag-2000;
        UITextField *countText = [alertView textFieldAtIndex:0];
        NSString *count = countText.text;
        SCOrderInMat *inMat = self.selArray[tag];
        double qty = [count doubleValue];
        if(qty+inMat.hasQty>inMat.limitQty){
            //数量过大
            [self.view makeToast:@"数量超过上限,请重新输入!" duration:3.0 position:CSToastPositionCenter];
        }else {
            inMat.qty = qty;
        }
        [self.tableView reloadData];
    }
}

-(void)delToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [self.unSelArray addObject:self.selArray[position]];
    [self.selArray removeObjectAtIndex:position];
    [self.tableView reloadData];
    double sum = 0;
    for(SCOrderInMat *inMat in self.selArray){
        sum = sum + inMat.qty;
    }
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu;总数量:%.2f",(unsigned long)self.selArray.count,sum];
}

/**
 *  确认入库,保存至数据库
 *
 *  @param sender
 */
- (void)confirmDealIn:(id)sender {
    double sum = 0;
    for(SCOrderInMat *inMat in self.selArray){
        sum = sum + inMat.qty;
    }
    if(self.selArray.count==0 || sum==0){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"尚未选择材料入库,请执行入库后再提交!"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        //保存数据库
        // TODO 涉及到出入库的数量判断
        NSDate *now = [NSDate date];
        NSString *deliverNo = [NSString stringWithFormat:@"%@%@",[DateTool dateToString:now],[DateTool randomNumber]];
        //保存入库单
        mIn = [[SCOrderMIn alloc] init];
        
        mIn.id = self.order.id;
        mIn.OrderId = self.order.OrderId;
        mIn.number = self.order.number;
        mIn.date = self.order.date;
        mIn.supplier = self.order.supplier;
        mIn.materialDesc = self.order.materialDesc;
        mIn.Addr = self.order.Addr;
        mIn.ProjectName= self.order.ProjectName;
        mIn.Company = self.order.Company;
        
        mIn.gid = [UUIDUtil getUUID];
        mIn.time = now;
        mIn.deliverNo = deliverNo;
        [mIn saveOrUpdate];//保存直入直出单
        
        
        for (int i = 0; i<self.selArray.count; i++) {
            SCOrderInMat *inMat = self.selArray[i];
            //之前处理的数量+这一次的处理数量
            inMat.hasQty = inMat.qty+inMat.hasQty;
            //如果已处理数量介于sourceQty和limitQty
            //则说明此次材料已处理结束
            if(inMat.hasQty>inMat.sourceQty && inMat.hasQty<inMat.limitQty){
                //此次处理完成
                inMat.isFinish = 1;
            }
            [inMat saveOrUpdate];
            //生成入库单
            SCIn *scIn = [[SCIn alloc] init];
            scIn.time = now;
            scIn.receiveid = mIn.gid;
            scIn.deliverNo = deliverNo;
            scIn.orderid = inMat.orderid;
            scIn.orderEntryid = inMat.orderentryid;
            scIn.qty = inMat.qty;
            [scIn saveOrUpdate];
        }
        int finish = 0;//判断单据是否结束:0,未结束  >0,已结束
        if(self.unSelArray.count>0){
            //未结束
            finish = 0;
        }else{
            for (int i = 0; i<self.selArray.count; i++) {
                SCOrderInMat *inMat = self.selArray[i];
                if(inMat.isFinish==0){
                    finish++;
                }
            }
        }
        
        
        if(finish==0){
            self.order.isFinish = 0;
        }else{
            self.order.isFinish = 1;
        }
        
        [self.order saveOrUpdate];
        //返回首页
        NSArray *controllers = self.navigationController.viewControllers;
        for(UIViewController *viewController in controllers){
            if([viewController isKindOfClass:[InDealViewController class]]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        
        
    }

}


@end
