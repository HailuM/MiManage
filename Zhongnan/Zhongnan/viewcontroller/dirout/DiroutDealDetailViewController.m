//
//  DiroutDealDetailViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "DiroutDealDetailViewController.h"
#import "UIView+Toast.h"

@interface DiroutDealDetailViewController ()

@end

@implementation DiroutDealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"直入直出选择";
    
    [self showOrder];
    UITapGestureRecognizer *checkAllTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkAll:)];
    self.checkLabel.userInteractionEnabled = YES;
    [self.checkLabel addGestureRecognizer:checkAllTap];
    
    UITapGestureRecognizer *chooseConsumerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseConsumer:)];
    self.consumerLabel.userInteractionEnabled = YES;
    [self.consumerLabel addGestureRecognizer:chooseConsumerTap];
    
    
    [self.confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
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
        if(!selArray){
            selArray = [[NSMutableArray alloc] init];
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
        if(self.consumer){
            self.consumerLabel.text = self.consumer.Name;
        }
        [self initData];
    }
}

/**
 *  选择领料商
 *
 *  @param sender <#sender description#>
 */
-(void)chooseConsumer:(id)sender{
    [self performSegueWithIdentifier:@"diroutdetailtochoose" sender:self];
}
/**
 *  跳转到确认界面
 *
 *  @param sender <#sender description#>
 */
-(void)confirm:(id)sender {
    if(selArray.count==0){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"请先选择物料信息!"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        [self performSegueWithIdentifier:@"confirmdirout" sender:self];
    }
}
/**
 *  查询订单上的材料
 */
-(void)initData {
    matArray = [PuOrderChild findByCriteria:[NSString stringWithFormat:@" WHERE orderid = '%@' and isFinish = 0 ",self.order.id]];
    unSelArray = [[NSMutableArray alloc] initWithArray:matArray];
    for(PuOrderChild *inMat in unSelArray){
        inMat.curQty = [NSString stringWithFormat:@"%f",[inMat.sourceQty doubleValue]-[inMat.rkQty doubleValue]];//默认当前的入库数量为订单上的sourceQty-已入库数量;如果<0,则,为0
        if([inMat.curQty doubleValue]<0){
            inMat.curQty = @"0";
        }
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)checkAll:(id)sender{
    
    if(!selArray){
        selArray = [[NSMutableArray alloc] init];
    }
    if(selArray.count==matArray.count){
        //已经全部选择
        self.checkLabel.text = @"全选";
        [unSelArray addObjectsFromArray:selArray];
        [selArray removeAllObjects];
        [self.checkBtn setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        
    }else{
        self.checkLabel.text = @"取消全选";
        [selArray addObjectsFromArray:unSelArray];
        [unSelArray removeAllObjects];
        [self.checkBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        
    }
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
    [self.tableView reloadData];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"confirmdirout"]){
        ConfirmDiroutViewController *viewController = segue.destinationViewController;
//        viewController.unSelArray = unSelArray;
        
        //把所有物料都加入到已经选择的物料
        
        
        viewController.selArray = selArray;
        [viewController.selArray addObjectsFromArray:unSelArray];
        viewController.order = self.order;
        viewController.consumer = self.consumer;
    }else if([segue.identifier isEqualToString:@"diroutdetailtochoose"]){
        ChooseConsumerViewController *viewController = segue.destinationViewController;
        viewController.flag = 1;
        viewController.orderid = self.order.id;
        viewController.delegate = self;
    }
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return unSelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailTableViewCell *cell = [OrderDetailTableViewCell cellWithTableView:tableView];
    cell.orderType = self.order.type;
    PuOrderChild *inMat = unSelArray[indexPath.row];
    [cell showCell:inMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn addTarget:self action:@selector(addToCheck:) forControlEvents:UIControlEventTouchUpInside];
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
    alert.tag = 4000+indexPath.row;
    PuOrderChild *inMat = unSelArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    //尾数去0
    countText.text = [StringUtil changeFloat:[NSString stringWithFormat:@"%f",[inMat.sourceQty doubleValue] - [inMat.rkQty doubleValue]]];
    [alert show];
}
/**
 *  减号 不能小于0
 *
 *  @param sender <#sender description#>
 */
-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *inMat = unSelArray[tag];
    double limit = 0;
    //获取最终上限
    double cur = [inMat.curQty doubleValue];
    double source = [inMat.sourceQty doubleValue];
    double rk = [inMat.rkQty doubleValue];
    
    
    
    if(cur-1<=0){
        cur = source-rk;
    }else{
        cur = cur-1;
    }
    inMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}


/**
 *  加号  不能大于limitQty-hasQty
 *
 *  @param sender <#sender description#>
 */
-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *inMat = unSelArray[tag];
    
    double cur = [inMat.curQty doubleValue];
    double source = [inMat.sourceQty doubleValue];
    double rk = [inMat.rkQty doubleValue];
    double limit = [inMat.limitQty doubleValue];
    
    if(cur+1>limit){
        cur = limit;
    }else{
        cur = cur+1;
    }
    inMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==alertView.firstOtherButtonIndex){
        NSInteger tag = alertView.tag-4000;
        UITextField *countText = [alertView textFieldAtIndex:0];
        NSString *count = countText.text;
        PuOrderChild *inMat = unSelArray[tag];
        
        double qty = [count doubleValue];
        
        
        double cur = [inMat.curQty doubleValue];
        double source = [inMat.sourceQty doubleValue];
        double rk = [inMat.rkQty doubleValue];
        double limit = [inMat.limitQty doubleValue];
        
        if(qty==0){
            //如果用户输入无效的字符串或者0
            cur = source-rk;
        }else{
            if(qty>limit){
                cur = limit;
                [self.view makeToast:@"数量超过上限!" duration:3.0 position:CSToastPositionCenter];
            }else{
                cur = qty;
            }
        }
        inMat.curQty = [NSString stringWithFormat:@"%f",cur];
        [self.tableView reloadData];
    }
}
-(void)pass:(id)value {
    self.consumer = value;
    if(self.consumer){
        self.consumerLabel.text = self.consumer.Name;
    }
}


- (void)addToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [selArray addObject:unSelArray[position]];
    [unSelArray removeObjectAtIndex:position];
    [self.tableView reloadData];
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)selArray.count];
}
@end
