//
//  ConfirmInViewController.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ConfirmInViewController.h"
#import "OrderImage.h"
#import "ImageToBase64.h"

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
//        double sum = 0;
//        for(PuOrderChild *inMat in self.selArray){
//            sum = sum + inMat.curQty;
//        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)self.selArray.count];
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
    cell.orderType = self.order.type;
    PuOrderChild *inMat = self.selArray[indexPath.row];
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
    alert.tag = 4000+indexPath.row;
    PuOrderChild *inMat = self.selArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    //尾数去0
    countText.text = [StringUtil changeFloat:inMat.curQty];
    [alert show];
}

-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *inMat = self.selArray[tag];
    
    double cur = [inMat.curQty doubleValue];
    double source = [inMat.sourceQty doubleValue];
    double rk = [inMat.rkQty doubleValue];
    //    double limit = [inMat.limitQty doubleValue];
    
    
    if(cur-1<=0){
        inMat.curQty = [NSString stringWithFormat:@"%f",source-rk];
    }else{
        cur = cur - 1;
        inMat.curQty = [NSString stringWithFormat:@"%f",cur];
    }
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *inMat = self.selArray[tag];
    
    double limit = 0;
    //获取最终上限
    if([inMat.limitQty doubleValue]<=0)
    {
        limit = [inMat.sourceQty doubleValue];
    } else {
        limit = [inMat.limitQty doubleValue];
    }
    double cur = [inMat.curQty doubleValue];
    double source = [inMat.sourceQty doubleValue];
    double rk = [inMat.rkQty doubleValue];
    
    if(cur+1>limit-rk){
        cur = limit-rk;
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
        PuOrderChild *inMat = self.selArray[tag];
        double qty = [count doubleValue];
        
        double cur = [inMat.curQty doubleValue];
        double source = [inMat.sourceQty doubleValue];
        double rk = [inMat.rkQty doubleValue];
        double limit = [inMat.limitQty doubleValue];
        //获取最终上限
        if(limit<=0)
        {
            limit = [inMat.sourceQty doubleValue];
        } else {
            limit = [inMat.limitQty doubleValue];;
        }
        
        if(qty<=0){
            //如果用户输入无效的字符串或者0
            cur = source-rk;
        }else{
            if(qty+rk>limit){
                //数量过大
                cur = limit-rk;
                [self.view makeToast:@"数量超过上限!" duration:3.0 position:CSToastPositionCenter];
            }else{
                cur = qty;
            }
        }
        
        inMat.curQty = [NSString stringWithFormat:@"%f",cur];
        [self.tableView reloadData];
        [self.tableView reloadData];
    }
}

-(void)delToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [self.unSelArray addObject:self.selArray[position]];
    [self.selArray removeObjectAtIndex:position];
    [self.tableView reloadData];
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)self.selArray.count];
}

/**
 *  确认入库,保存至数据库
 *
 *  @param sender
 */
- (void)confirmDealIn:(id)sender {
    double sum = 0;
    for(PuOrderChild *inMat in self.selArray){
        sum = sum + [inMat.curQty doubleValue];
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
        [self saveOrder];
        
        sheet = [[IBActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        [sheet setFont:[UIFont systemFontOfSize:15.f]];
        [sheet setButtonTextColor:[UIColor blackColor]];
        [sheet setButtonBackgroundColor:[UIColor whiteColor]];
        [sheet showInView:self.view];
        
    }

}


-(void)saveOrder{
    // TODO 涉及到出入库的数量判断
    NSDate *now = [NSDate date];
    //        NSString *deliverNo = [NSString stringWithFormat:@"%@%@",[DateTool dateToString:now],[DateTool randomNumber]];
    //保存入库单
    bill = [[InBill alloc] init];
    
    
    bill.receiveid = [UUIDUtil getUUID];
    bill.orderid = self.order.id;
    bill.date = self.order.date;
    bill.supplier = self.order.supplier;
    bill.materialDesc = self.order.materialDesc;
    bill.Addr = self.order.Addr;
    bill.ProjectName= self.order.ProjectName;
    bill.Company = self.order.Company;
    bill.preparertime = [DateTool datetimeToString:now];
    
    
    
    [bill saveOrUpdate];//保存入库单
    //手机根据刚刚做的入库单生成新的出库来源订单主表
    rkOrder = [[PuOrder alloc] init];
    rkOrder.id = [UUIDUtil getUUID];//手机生成的入库单id
    rkOrder.sourceid = self.order.id;
    rkOrder.number = [StringUtil generateNo:@"SCRK"];
    rkOrder.supplier = self.order.supplier;
    rkOrder.materialDesc = self.order.materialDesc;
    rkOrder.Addr = self.order.Addr;
    rkOrder.type = @"rkck";
    rkOrder.zcwc = NO;
    rkOrder.name = self.order.name;
    rkOrder.ProjectName = self.order.ProjectName;
    rkOrder.Company = self.order.Company;
    rkOrder.date = [DateTool dateWithString:now];
    rkOrder.isFinish = 0;
    
    [rkOrder saveOrUpdate];
    
    for (int i = 0; i<self.selArray.count; i++) {
        PuOrderChild *inMat = self.selArray[i];
        //之前处理的数量+这一次的处理数量
        inMat.rkQty = [NSString stringWithFormat:@"%f",[inMat.curQty doubleValue]+[inMat.rkQty doubleValue]];
        //如果已处理数量介于sourceQty和limitQty
        //则说明此次材料已处理结束
        if([inMat.rkQty doubleValue]>=[inMat.sourceQty doubleValue] && [inMat.rkQty doubleValue]<=[inMat.limitQty doubleValue]){
            //此次处理完成
            inMat.isFinish = 1;
        }
        [inMat saveOrUpdate];
        //生成入库单子表
        InBillChild *billC = [[InBillChild alloc] init];
        billC.receiveid = bill.receiveid;
        billC.wareentryid = [UUIDUtil getUUID];
        billC.qty = inMat.curQty;
        billC.orderEntryid = inMat.orderentryid; //来源单据的表体id
        billC.preparertime = bill.preparertime;
        billC.orderid = bill.orderid;
        billC.xsxh = inMat.xsxh;
        
        if(![InBillChild isExistInTable]){
            [InBillChild createTable];
        }
        [billC saveOrUpdate];
        
        
        //child
        PuOrderChild *rkChild = [[PuOrderChild alloc] init];
        //rkChild 生成入库单的子表
        //            rkChild.orderentryid = [UUIDUtil getUUID];
        rkChild.orderentryid = inMat.orderentryid;
        
        rkChild.orderid = rkOrder.id;
        
        rkChild.xsxh = inMat.xsxh;
        rkChild.sourceid = inMat.orderid;
        rkChild.sourcecid = bill.receiveid;
        rkChild.isFinish = 0;
        rkChild.note = inMat.note;
        rkChild.brand = inMat.brand;
        rkChild.model = inMat.model;
        rkChild.Name = inMat.Name;
        rkChild.price = inMat.price;
        rkChild.ckQty = 0;
        rkChild.sourceQty = inMat.curQty;
        rkChild.wareentryid = billC.wareentryid;
        /////如果是手机生成入库单,那么材料明细的wareentryid是手机生成的,带到出库单明细的wareentryid
        [rkChild saveOrUpdate];
        
    }
    
    
    int finish = 0;//判断单据是否结束:0,未结束  >0,已结束
    if(self.unSelArray.count>0){
        //未结束
        finish = 1;
    }else{
        
        for (int i = 0; i<self.selArray.count; i++) {
            PuOrderChild *inMat = self.selArray[i];
            if(inMat.isFinish==0){
                finish++;
            }
        }
        
    }
    
    
    if(finish>0){
        //有材料未完成
        self.order.isFinish = 0;
    }else{
        self.order.isFinish = 1;
    }
    self.order.zcwc = 1;
    [self.order saveOrUpdate];
}

#pragma mark - IBActionSheet delegate
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == sheet.cancelButtonIndex){
        //不上传图片
        //返回首页
        NSArray *controllers = self.navigationController.viewControllers;
        for(UIViewController *viewController in controllers){
            if([viewController isKindOfClass:[MainViewController class]]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
    if(buttonIndex == 0){
        //拍照
        
        SCCNavigationController *nav = [[SCCNavigationController alloc] init];
        nav.scNaigationDelegate = self;
        [nav showCameraWithParentController:self];
        
    }else if(buttonIndex == 1){
        //从手机相册选择
        
        DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
        cont.delegate = self;
        cont.nMaxCount = -1;
        cont.nColumnCount = 3;
        [self presentViewController:cont animated:YES completion:nil];
    }
}

#pragma mark - SCNavigationController delegate
//拍照委托
- (void)didTakePicture:(SCCNavigationController *)navigationController image:(UIImage *)image {
    [navigationController dismissModalViewControllerAnimated:YES];
    //将图片转成字符串保存到数据库
    NSString *imageData = [ImageToBase64 imageWithNoCompressToBase64:image];
    OrderImage *orderImage = [[OrderImage alloc] init];
    orderImage.orderId = bill.receiveid;
    orderImage.type= @"rk";
    orderImage.imageData = imageData;
    [orderImage saveOrUpdate];
    
//    //弹出alert是否继续拍照
//    sheet = [[IBActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
//    [sheet setFont:[UIFont systemFontOfSize:15.f]];
//    [sheet setButtonTextColor:[UIColor blackColor]];
//    [sheet setButtonBackgroundColor:[UIColor whiteColor]];
//    [sheet showInView:self.view];
    
}


-(BOOL)willDismissNavigationController:(SCCNavigationController *)navigatonController {
    if(sheet){
        [sheet showInView:self.view];
    }else{
        //弹出alert是否继续拍照
        sheet = [[IBActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        [sheet setFont:[UIFont systemFontOfSize:15.f]];
        [sheet setButtonTextColor:[UIColor blackColor]];
        [sheet setButtonBackgroundColor:[UIColor whiteColor]];
        [sheet showInView:self.view];
    }
    return YES;
}
#pragma mark - DoImagePickerControllerDelegate
//选择照片的委托
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        if(aSelected && aSelected.count >0){
            
            for(UIImage *image in aSelected){
                NSString *imageData = [ImageToBase64 imageWithNoCompressToBase64:image];
                OrderImage *orderImage = [[OrderImage alloc] init];
                orderImage.orderId = bill.receiveid;
                orderImage.type= @"rk";
                orderImage.imageData = imageData;
                [orderImage saveOrUpdate];
            }
        }
        
        
        
        //返回首页
        NSArray *controllers = self.navigationController.viewControllers;
        for(UIViewController *viewController in controllers){
            if([viewController isKindOfClass:[MainViewController class]]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}

@end
