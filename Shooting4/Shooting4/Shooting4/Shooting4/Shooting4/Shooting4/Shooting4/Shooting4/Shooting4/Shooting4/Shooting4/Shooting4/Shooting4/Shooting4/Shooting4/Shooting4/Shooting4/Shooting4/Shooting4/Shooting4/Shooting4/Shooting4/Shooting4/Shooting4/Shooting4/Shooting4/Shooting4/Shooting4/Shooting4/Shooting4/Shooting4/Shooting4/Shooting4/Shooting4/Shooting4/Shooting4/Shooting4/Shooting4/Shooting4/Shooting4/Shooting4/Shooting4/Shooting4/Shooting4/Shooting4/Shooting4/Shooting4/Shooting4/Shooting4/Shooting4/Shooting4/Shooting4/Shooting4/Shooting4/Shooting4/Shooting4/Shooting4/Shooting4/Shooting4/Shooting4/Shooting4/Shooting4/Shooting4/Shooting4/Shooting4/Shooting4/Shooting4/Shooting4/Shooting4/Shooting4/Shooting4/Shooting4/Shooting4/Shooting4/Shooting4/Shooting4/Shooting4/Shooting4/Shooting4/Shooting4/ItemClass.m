//
//  ItemClass.m
//  Shooting4
//
//  Created by 遠藤 豪 on 13/10/02.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "ItemClass.h"

@implementation ItemClass

-(id) init:(int)x_init y_init:(int)y_init width:(int)w height:(int)h{
    
    y_loc = y_init;
    x_loc = x_init;
    width = w;
    height = h;
    isAlive = true;
    rect = CGRectMake(x_loc, y_loc, w, h);
    iv = [[UIImageView alloc]initWithFrame:rect];
    //    iv.image = [UIImage imageNamed:@"beam.png"];
    iv.image = [UIImage imageNamed:@"item.png"];
    return self;
}
-(id) init{
    NSLog(@"call enemy class initialization");
    return [self init:0 y_init:0 width:10 height:10];
}

-(Boolean) getIsAlive{
    return isAlive;
}


-(void) die{
    isAlive = false;
}
-(void) setLocation:(CGPoint)loc{
    x_loc = (int)loc.x;
    y_loc = (int)loc.y;
}

-(void)setX:(int)x{
    x_loc = x;
}
-(void)setY:(int)y{
    y_loc = y;
}

-(CGPoint) getLocation{
    return CGPointMake((float)x_loc, (float)y_loc);
}

-(int) getX{
    return x_loc;
}

-(int) getY{
    return y_loc;
}

-(UIImageView *)getImageView{
    //    [iv removeFromSuperview];
    //ここでivに代入するとself.viewに張り付いているivとは別オブジェクトが新規に生成されてしまう。
    //=>だからdoNextで移動距離を計算し、そこでivも作ってしまうことに。
    //    rect = CGRectMake(x_loc, y_loc, mySize, mySize);
    //    iv = [[UIImageView alloc]initWithFrame:rect];
    //    iv.image = [UIImage imageNamed:@"enemy.png"];
    return iv;
}


@end
