//
//  BaseViewController.m
//  finance
//
//  Created by Atimu on 17-8-7.
//  Copyright (c) 2017年 Atimu. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"
#import "ActivationViewController.h"
#import "TradeSuccessViewController.h"
@interface BaseViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSTimer *priceTimer;
@property(nonatomic,copy) NSString *typeCode;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem* back = [self backButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, back];
}

-(UIBarButtonItem *)backButton{
    UIImage *image = [UIImage imageNamed:@"back_navi.png"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"back_navi_h.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

-(void)backButtonPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tradeSuccessView) name:@"tradeSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonPressed) name:@"logOut" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:@"tradeSuccess"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"logOut"];
}

-(void)tradeSuccessView{
    [kkTabbar setHidden:YES];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Trade" bundle:nil];
    TradeSuccessViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TradeSuccessViewController"];
    viewController.ExchangeTypeID = [AppModel shareInstance].ExchangeTypeID;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:navi animated:YES completion:nil];
}

//创建无数据时的View
-(void)createNoDataView{
    self.noDataView = [[UIView alloc] initWithFrame:CGRectMake((kkMainScreen.size.width-200)/2, 100, 200, 200)];
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake((200-99)/2, 10, 99, 86)];
    image.image = [UIImage imageNamed:@"noData.png"];
    [self.noDataView addSubview:image];
    
    UILabel *text1=[[UILabel alloc]initWithFrame:CGRectMake(0, 110, 200, 25)];
    text1.text = @"暂无数据";
    text1.textAlignment = NSTextAlignmentCenter;
    text1.textColor=[UIColor grayColor];
    text1.backgroundColor=[UIColor clearColor];
    text1.numberOfLines=0;
    text1.font=[UIFont systemFontOfSize:16.0f];
    self.noDataLabel = text1;
    [self.noDataView addSubview:text1];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button setBackgroundImage:[UIImage imageNamed:@"No_data_button.png"] forState:(UIControlStateNormal)];
    [button setTitle:@"更新加载" forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.frame = CGRectMake((200-125)/2, 150, 125, 31);
    self.noDataButton = button;
    [self.noDataView addSubview:self.noDataButton];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)showCustomView:(NSString *)msg andImageName:(NSString *)imageName{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    if (!IOS8) {
        hud.yOffset = -50.f;
    }
    // Set custom view mode
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    hud.mode = MBProgressHUDModeCustomView;

    hud.delegate = self;
    hud.labelText = msg;
    [hud show:YES];
}

-(void)showToast:(NSString*)msg{
    [self hideProgress];
    //自定义view
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
    if (!iPhone5) {
        HUD.yOffset = -60.f;
    }
    [self.view addSubview:HUD];
    HUD.labelText = msg;
    HUD.mode = MBProgressHUDModeText;
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2.5);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

-(void)showProgress:(NSString*)msg{
//    kkTabbar.userInteractionEnabled = NO;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (!IOS8) {
        hud.yOffset = -50.f;
    }
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = msg;
    hud.animationType = MBProgressHUDAnimationFade;
     //30秒后隐藏progress
    [self performSelector:@selector(hideProgress) withObject:nil afterDelay:30];

}

-(void)hideProgress{
    kkTabbar.userInteractionEnabled = YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
}

-(void)hideProgressFailed{
    kkTabbar.userInteractionEnabled = YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)showRefreshMessage:(NSString*)msg andYAdjust:(float)yAdjust{
    if (self.showView) {
        self.showView.hidden = NO;
//        [self.showView removeFromSuperview];
//        self.showView = nil;
        return;
    }
    CGRect frame = self.view.frame;
    frame.origin.y = yAdjust;
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.userInteractionEnabled = YES;
    [self.view addSubview:view];
    self.showView = view;
    
    UIImageView* imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(136, 70, 48, 48)];
    imageView3.image = [[UIImage imageNamed:@"no_internet.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9,9,9,9) resizingMode:UIImageResizingModeStretch];
    [view addSubview:imageView3];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 130, 200, 50)];
    label.text = msg;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = [UIColor colorWith256Red:170 green:170 blue:170 alpha:1];
    [label setNumberOfLines:0];
    [view addSubview:label];
    
    UIButton* submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(8, 230, 304, 40);
    [submit setTitle:@"重新加载" forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:18.0];
    submit.titleLabel.textColor = [UIColor whiteColor];
    submit.backgroundColor = [UIColor clearColor];
    UIImage* buttonImage = [[UIImage imageNamed:@"login_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9,9,9,9) resizingMode:UIImageResizingModeStretch];
    UIImage* buttonHighlighted = [[UIImage imageNamed:@"button_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(9,9,9,9) resizingMode:UIImageResizingModeStretch];
    [submit setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [submit setBackgroundImage:buttonHighlighted forState:UIControlStateHighlighted];
    [view addSubview:submit];
    [submit addTarget:self action:@selector(refreshing) forControlEvents:UIControlEventTouchUpInside];
}

-(void)refreshing{
     self.showView.hidden = YES;
     [self.showView removeFromSuperview];
     self.showView = nil;
}

-(void)refreshInvestorList:(BOOL)show{
    if (show) {
        [self showProgress:@"正在加载..."];
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [[AFNRequest sharedInstance] postRequest:[InvestRequestAPI getInvestorInfo] ReqParam:param success:^(AFHTTPRequestOperation *operation, NSString* responseObject) {
        [self hideProgress];
        NSDictionary* dictionary = [UTilities decodeAESString:responseObject];
        if (dictionary == nil) {
            return ;
        }
        if (show) {
            NSLog(@"%@",dictionary);
        }
        if ([dictionary[@"ResultCD"] isEqualToString:@"I001"]){
            kkInvestorInfo.headUrl = dictionary[@"userAvatar"];
            kkInvestorInfo.idNum = dictionary[@"AuthNumber"];
            kkInvestorInfo.name = [dictionary[@"AuthName"] stringByRemovingPercentEncoding];;
            kkInvestorInfo.nickname = [dictionary[@"userName"] stringByRemovingPercentEncoding];
            kkInvestorInfo.integral = [dictionary[@"integral"] floatValue];
            kkInvestorInfo.Balance = [dictionary[@"Balance"] floatValue];

            //kkLoginToken
            for (NSDictionary* dic in dictionary[@"Customer"]) {
                if (![UTilities isBlankString:dic[@"SessionID"]]) {
                    NSDictionary *account = [AppModel shareInstance].accountList[dic[@"ExchangeTypeID"]];
                    [account setValue:dic[@"ExchangeOpenState"] forKey:@"isActive"];
                    [account setValue:dic[@"SessionID"] forKey:@"SessionID"];
                    [account setValue:dic[@"Balance"] forKey:@"Balance"];
                    [account setValue:dic[@"Cost"] forKey:@"Cost"];
                }
            }
            self.currentState = 1;
        }else{
           if ([dictionary[@"ResultCD"] isEqualToString:@"EC03"] || [dictionary[@"ResultCD"] isEqualToString:@"EC99"]){
//               [UTilities logoutSetting];
               [self backButtonPressed];
           }else{
               [self showToast:dictionary[@"ErrorMsg"]];
           }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideProgress];
        [self performSelector:@selector(refreshInvestorList:) withObject:nil afterDelay:20];
    }];
}

-(void)addPriceTimer:(NSString*)TypeCode{
    [self removePriceTimer];
    self.typeCode = TypeCode;
    self.priceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshPriceList:) userInfo:nil repeats:YES];
    [self.priceTimer fire];
}

-(void)removePriceTimer{
    [self.priceTimer invalidate];
    self.priceTimer = nil;
}

-(void)refreshPriceList:(NSTimer*)sender{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.typeCode.length > 0) {
        [param setObject:self.typeCode forKey:@"goodsType"];
    }
    [[AFNRequest sharedInstance] get:[InvestRequestAPI getPriceList] ReqParam:param success:^(AFHTTPRequestOperation *operation, NSString* responseObject) {
        [self hideProgress];
        NSMutableDictionary*dictionary = [responseObject objectFromJSONString];
        if (dictionary == nil) {
            NSLog(@"当前报价接口出错");
            return ;
        }
        BOOL show = NO;
        for (int i = 0;i < [AppModel shareInstance].priceArray.count ;i++) {
            GoodsModel *model = [AppModel shareInstance].priceArray[i];
            for (NSDictionary *dic in dictionary[@"PriceList"]){
                GoodsModel *goods = [RMMapper objectWithClass:[GoodsModel class] fromDictionary:dic];
                if ([goods.TypeCode isEqualToString:model.TypeCode] && [goods.ExchangeTypeID isEqualToString:model.ExchangeTypeID]) {
                    goods.Name = model.Name;
                    goods.StartTime = model.StartTime;
                    goods.EndTime = model.EndTime;
                    goods.index = model.index;
                    goods.dataIndex = model.dataIndex;
                    goods.MarketStatus = model.MarketStatus;
                    goods.ExchangeTypeID = model.ExchangeTypeID;
                    [[AppModel shareInstance].priceArray replaceObjectAtIndex:i withObject:goods];
                    
                    if (model.CurPrice != goods.CurPrice && ![model.PriceTime isEqualToString:goods.PriceTime]) {
                        show = YES;
                    }
                }
            }
        }
        if (show) {
            self.currentState = 2;
            [AppModel shareInstance].priceArray = [AppModel shareInstance].priceArray;
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideProgress];
        [self performSelector:@selector(refreshPriceList:) withObject:nil afterDelay:20];
    }];
}

-(BOOL)checkLoginActiveState:(NSString*)ExchangeTypeID{
    if (kkLoginState > 0) {
        NSDictionary *account = [AppModel shareInstance].accountList[ExchangeTypeID];
        if ([account[@"isActive"] integerValue] == 0) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:nil];
            ActivationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ActivationViewController"];
            viewController.ExchangeTypeID = ExchangeTypeID;
            [self.navigationController pushViewController:viewController animated:YES];
            return NO;
        }
    }else{
        //登陆
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController * login = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:login animated:YES];
        return NO;
    }
    return YES;
}

-(UIView *)createADView{
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame =  CGRectMake(0, 0, kkScreenWidth, 90);
    [button addTarget:self action:@selector(pushADView) forControlEvents:UIControlEventTouchUpInside];
    [button sd_setImageWithURL:[AppModel shareInstance].adViewData[@"AdUrl"] forState:(UIControlStateNormal)];
    return button;
}

-(void)pushADView{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FindWebViewController * webView = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.webContent = [AppModel shareInstance].adViewData[@"LinkUrl"];
    if ([[AppModel shareInstance].adViewData[@"Title"] length] == 0) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        webView.title =  [infoDictionary objectForKey:@"CFBundleDisplayName"];
    }else{
        webView.title = [AppModel shareInstance].adViewData[@"Title"];
    }
    [self.navigationController pushViewController:webView animated:YES];
}
@end
