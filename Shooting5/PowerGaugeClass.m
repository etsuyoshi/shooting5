//
//  PowerGaugeClass.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/03.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "PowerGaugeClass.h"

@implementation PowerGaugeClass

-(id)init:(int)type x_init:(int)x y_init:(int)y width:(int)w height:(int)h{
//    [super init];
    
    iv_gauge = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    iv_gauge.image = [UIImage imageNamed:[@"powerGauge_" stringByAppendingString:@"100"]];
    iv_gauge.alpha = 0.3;//透過性
    
    //背景画像を透過させる方法
//    UIColor *color = [UIColor grayColor];
//    UIColor *alphaColor = [color colorWithAlphaComponent:0.5];
//    iv_gauge.backgroundColor = alphaColor;
    return self;
}

-(void)setValue:(int)_value{
    value = _value;
}

-(UIImageView *)getImageView{
    [iv_gauge removeFromSuperview];
    if(value > 0){
        
        NSString *_fileName = [NSString stringWithFormat:@"powerGauge_%d.png", (int)(value/10) * 10];
    
    
//    iv_gauge.image = [UIImage imageNamed:[@"powerGauge_" stringByAppendingString:@"90"]];
        iv_gauge.image = [UIImage imageNamed:_fileName];
    }
    return iv_gauge;
}

-(void)setAngle:(double)_angle{
    angle = _angle;
    iv_gauge.transform = CGAffineTransformMakeRotation(angle);
    
}

-(double)getAngle{
    return angle;
}

@end
