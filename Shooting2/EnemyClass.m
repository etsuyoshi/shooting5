//
//  EnemyClass.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/26.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//


#import "EnemyClass.h"

@implementation EnemyClass

int x_loc, y_loc;
int mySize;
Boolean isAlive;

-(id) init:(int)x_init{
    y_loc = 0;
    x_loc = x_init;
    isAlive = true;
    return self;
}

-(Boolean) getIsAlive{
    return isAlive;
}

-(void)setSize:(int)s{
    mySize = s;
}

-(void)doNext{
    y_loc += mySize;
    x_loc += mySize * (arc4random() % 3) * pow(-1, arc4random()%2);//単位時間当たりに左右3個体分の移動距離を進む
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



@end
