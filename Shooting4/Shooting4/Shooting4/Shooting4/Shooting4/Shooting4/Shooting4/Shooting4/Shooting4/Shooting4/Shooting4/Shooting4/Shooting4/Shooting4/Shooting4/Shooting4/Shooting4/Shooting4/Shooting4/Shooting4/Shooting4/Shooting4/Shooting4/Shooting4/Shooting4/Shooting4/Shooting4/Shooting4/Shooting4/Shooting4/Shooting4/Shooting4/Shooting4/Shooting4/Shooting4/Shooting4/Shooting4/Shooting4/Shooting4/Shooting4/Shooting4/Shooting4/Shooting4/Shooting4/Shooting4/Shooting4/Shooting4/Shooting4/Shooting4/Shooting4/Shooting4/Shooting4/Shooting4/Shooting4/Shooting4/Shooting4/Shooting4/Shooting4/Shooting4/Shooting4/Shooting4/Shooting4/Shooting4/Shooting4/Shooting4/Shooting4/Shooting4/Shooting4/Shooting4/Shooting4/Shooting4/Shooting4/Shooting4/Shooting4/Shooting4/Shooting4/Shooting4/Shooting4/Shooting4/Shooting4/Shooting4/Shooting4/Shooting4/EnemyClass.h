//
//  EnemyClass.h
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/26.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWFParticleView.h"

@interface EnemyClass : NSObject{
    
    int x_loc;
    int y_loc;
    int enemy_type;//機体の型
    int mySize;
    int lifetime_count;
    int bomb_size;
    int dead_time;
    Boolean isAlive;
    UIImageView *iv;
    CGRect rect;
    DWFParticleView *particleView;

}


-(id)init:(int)x_init size:(int)size;
-(id)init;

-(Boolean)getIsAlive;
-(int)getDeadTime;
-(void)setSize:(int)s;
-(int)getSize;

-(void)doNext;

-(void) die:(CGPoint)loc;
-(void)setLocation:(CGPoint)loc;
-(void)setX:(int)x;
-(void)setY:(int)y;

-(CGPoint) getLocation;
-(int) getX;
-(int) getY;
-(UIImageView *)getImageView;
-(DWFParticleView *)getParticle;
@end
