//
//  ADView.m
//  Finance
//
//  Created by Atimu on 15/9/9.
//  Copyright (c) 2015年 tiantai. All rights reserved.
//

#import "ADView.h"

@implementation ADView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.frame = kkMainScreen;
    [kkTabbar setUserEnabled:NO];
    self.time = 0;
    if ([AppModel shareInstance].adViewData.allKeys.count > 0) {
 
        [self.imageViewBack sd_setImageWithURL:[NSURL URLWithString:[AppModel shareInstance].adViewData[@"eImgUrl"]] placeholderImage:[UIImage imageNamed:@"imageNormal"]];
    }else {
        if (!iPhone5) {
            self.imageViewBack.image = [UIImage imageNamed:@"Default.png"];
        }else {
            self.imageViewBack.image = [UIImage imageNamed:@"Default-568h.png"];
        }
        self.time = 0;
    }
    
//    [self performSelector:@selector(removeView:) withObject:nil afterDelay:0];
   
}

- (IBAction)removeView:(UIButton *)sender {
    if (self.time == 0 ) {
        [kkTabbar setHidden:NO];
        [kkTabbar setUserEnabled:YES];
        [self removeFromSuperview];
    }else{
        self.labelTime.text = [NSString stringWithFormat:@"%zds后跳过",self.time];
        self.time--;
        [self performSelector:@selector(removeView:) withObject:nil afterDelay:1];
    }
}

- (IBAction)goNext:(UIButton *)sender {
    if (self.type == 0) {
        if ([[AppModel shareInstance].adViewData[@"LinkUrl"] length] > 0) {
            [kkTabbar setHidden:NO];
            [kkTabbar setUserEnabled:YES];
            [self removeFromSuperview];
            //广告跳转
//            kkCurrentViewState = CurrentView_ADView;
        }
    }else{
        self.time = 0;
        [self performSelector:@selector(removeView:) withObject:nil afterDelay:0];
    }

}
@end
