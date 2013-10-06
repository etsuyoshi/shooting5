//
//  EnemyClass.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/26.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//


#import "EnemyClass.h"

@implementation EnemyClass

int unique_id;
-(id) init:(int)x_init size:(int)size{
    unique_id++;
    y_loc = 0;
    x_loc = x_init;
    mySize = size;
    isAlive = true;
    rect = CGRectMake(x_loc, y_loc, mySize, mySize);
    iv = [[UIImageView alloc]initWithFrame:rect];
    switch(arc4random() % 3){
        case 0:
            enemy_type = 0;
            iv.image = [UIImage imageNamed:@"enemy01_stand_128.png"];
            break;
        case 1:
            enemy_type = 1;
            iv.image = [UIImage imageNamed:@"enemy02_stand_128.png"];
            break;
        case 2:
            enemy_type = 2;
            iv.image = [UIImage imageNamed:@"enemy03_stand_128.png"];
            break;
    }
    
    
    return self;
}
-(id) init{
    NSLog(@"call enemy class initialization");
    return [self init:0 size:50];
}

-(Boolean) getIsAlive{
    return isAlive;
}

-(void)setSize:(int)s{
    mySize = s;
}
-(int)getSize{
    return mySize;
}
-(void)doNext{
    
//    [iv removeFromSuperview];
//    NSLog(@"更新前 y = %d", y_loc);
    y_loc += mySize/4;
    x_loc += mySize/10 * (int)pow(-1, arc4random()%2) % 200;//単位時間当たりに左右3個体分の移動距離を進む
    iv = [[UIImageView alloc]initWithFrame:CGRectMake(x_loc, y_loc, mySize, mySize)];

    
    switch(enemy_type){
        case 0:
            enemy_type = 0;
            iv.image = [UIImage imageNamed:@"enemy01_stand_128.png"];
            break;
        case 1:
            enemy_type = 1;
            iv.image = [UIImage imageNamed:@"enemy02_stand_128.png"];
            break;
        case 2:
            enemy_type = 2;
            iv.image = [UIImage imageNamed:@"enemy03_stand_128.png"];
            break;
    }


//    NSLog(@"更新後 y = %d", y_loc);
//    rect = CGRectMake(x_loc, y_loc, mySize, mySize);
//    iv = [[UIImageView alloc]initWithFrame:rect];
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
