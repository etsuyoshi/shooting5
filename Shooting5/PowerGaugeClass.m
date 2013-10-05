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
    value = 100;
    iv_gauge = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,w,h)];
//    iv_gauge.image = [UIImage imageNamed:[@"powerGauge_pt" stringByAppendingString:@"0.png"]];
    iv_gauge.image = [UIImage imageNamed:@"powerGauge_pt0.png"];
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

-(int)getValue{
    return value;
}

-(UIImageView *)getImageView{
    [iv_gauge removeFromSuperview];

    int devide_num = 16;
    double unit = 100/(double)devide_num;
//    NSLog(@"d = %d, u = %f, 誤差=%d",devide_num, unit, tolerant);
    NSString *_fileName;
    for(int count = 0;count <= devide_num; count++){//count<devide_numとしてしまうと余りが考慮されない
//        NSLog(@"value=%d, unit=%f, count=%d, ", value, unit, count);
        if(value > count * unit && value <= (count + 1) * unit){
//            NSLog(@"value = %d, count = %d", value, count);
            _fileName = [NSString stringWithFormat:@"powerGauge_pt%d.png", devide_num - count - 1];
        }
    }
    
//    iv_gauge.image = [UIImage imageNamed:[@"powerGauge_" stringByAppendingString:@"90"]];
    iv_gauge.image = [UIImage imageNamed:_fileName];//valueが0-100の間になければfilenameはnullのまま非表示となる
    
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
