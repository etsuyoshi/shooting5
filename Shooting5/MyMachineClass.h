//
//  MyMachineClass.h
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/04.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWFParticleView.h"
#import "DamageParticleView.h"

@interface MyMachineClass : NSObject{
    
    int x_loc;
    int y_loc;
    int machine_type;//機体の型
    int hitPoint;
    int mySize;
    int lifetime_count;
    int bomb_size;
    int dead_time;
    Boolean isAlive;
    UIImageView *iv;
    CGRect rect;
    DWFParticleView *explodeParticle;
    DamageParticleView *damageParticle;
}


-(id)init:(int)x_init size:(int)size;
-(id)init;

-(void)setDamage:(int)damage location:(CGPoint)location;
-(int)getHitPoint;
-(Boolean)getIsAlive;
-(int)getDeadTime;
-(void)setSize:(int)s;
-(int)getSize;

-(void)doNext;

-(void)die:(CGPoint)loc;
-(void)setLocation:(CGPoint)loc;
-(void)setX:(int)x;
-(void)setY:(int)y;

-(CGPoint) getLocation;
-(int) getX;
-(int) getY;
-(UIImageView *)getImageView;
-(DWFParticleView *)getExplodeParticle;
-(DamageParticleView *)getDamageParticle;

@end
