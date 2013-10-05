//
//  BeamClass.m
//  Shooting3
//
//  Created by 遠藤 豪 on 13/09/28.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "BeamClass.h"

@implementation BeamClass
-(id) init:(int)x_init y_init:(int)y_init width:(int)w height:(int)h{
    
    y_loc = y_init;
    x_loc = x_init;
    power = 10;//衝突対象に対するダメージ
    width = w;
    height = h;
    isAlive = true;
    rect = CGRectMake(x_loc, y_loc, w, h);
    iv = [[UIImageView alloc]initWithFrame:rect];
//    iv.image = [UIImage imageNamed:@"beam.png"];
    iv.image = [UIImage imageNamed:@"bullet_level1.png"];
    return self;
}
-(id) init{
    NSLog(@"call enemy class initialization");
    return [self init:0 y_init:0 width:10 height:10];
}

-(Boolean) getIsAlive{
    return isAlive;
}

-(void)doNext{
    
    //    [iv removeFromSuperview];
    //    NSLog(@"更新前 y = %d", y_loc);
    y_loc -= height;
    x_loc += 0;//mySize/10 * (int)pow(-1, arc4random()%2) % 200;//単位時間当たりに左右3個体分の移動距離を進む
    iv = [[UIImageView alloc]initWithFrame:CGRectMake(x_loc, y_loc, width, height)];
//    iv.image = [UIImage imageNamed:@"beam.png"];
    iv.image = [UIImage imageNamed:@"bullet_level1.png"];
    
    //    NSLog(@"更新後 y = %d", y_loc);
    //    rect = CGRectMake(x_loc, y_loc, mySize, mySize);
    //    iv = [[UIImageView alloc]initWithFrame:rect];
}

-(int)getPower{
    return power;
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

-(int)getSize{
    return width;
}

-(UIImageView *)getImageView{
    return iv;
}

@end
