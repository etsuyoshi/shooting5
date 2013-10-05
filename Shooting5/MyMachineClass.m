//
//  MyMachineClass.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/04.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "MyMachineClass.h"

@implementation MyMachineClass

int unique_id;
-(id) init:(int)x_init size:(int)size{
    unique_id++;
    y_loc = 300;
    x_loc = x_init;
    hitPoint = 100;
    mySize = size;
    lifetime_count = 0;
    dead_time = -1;//死亡したら0にして一秒後にparticleを消去する
    isAlive = true;
    explodeParticle = nil;
    damageParticle  = nil;
    rect = CGRectMake(x_loc, y_loc, mySize, mySize);
    iv = [[UIImageView alloc]initWithFrame:rect];
    machine_type = arc4random() % 3;
    switch(machine_type){
        case 0:
            bomb_size = 20;
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
        case 1:
            bomb_size = 30;
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
        case 2:
            bomb_size = 40;
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
    }
    
    
    return self;
}
-(id) init{
    NSLog(@"call mymachine class ""DEFAULT"" initialization");
    return [self init:0 size:50];
}

-(void)setDamage:(int)damage location:(CGPoint)location{
    damageParticle = [[DamageParticleView alloc] initWithFrame:CGRectMake(location.x, location.y, damage, damage)];
    hitPoint -= damage;
    if(hitPoint < 0){
        [self die:location];
    }
}

-(void) die:(CGPoint) location{
    //爆発用パーティクルの初期化
    explodeParticle = [[DWFParticleView alloc] initWithFrame:CGRectMake(location.x, location.y, bomb_size, bomb_size)];
    isAlive = false;
    dead_time ++;
}


-(int)getHitPoint{
    return hitPoint;
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
    lifetime_count ++;//不要？
    if(!isAlive){
        dead_time ++;
    }
    
//            NSLog(@"machine iv generated");    
    iv = [[UIImageView alloc]initWithFrame:CGRectMake(x_loc, y_loc, mySize, mySize)];
    
    
    switch(machine_type){
        case 0:
//            NSLog(@"machine iv generated");
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
        case 1:
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
        case 2:
            iv.image = [UIImage imageNamed:@"gradius02_stand_128.png"];
            break;
    }
    
}

-(int) getDeadTime{
    return dead_time;
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
    return iv;
}

-(DWFParticleView *)getExplodeParticle{
    //dieしていれば爆発用particleは初期化されているはず=>描画用クラスで描画(self.view addSubview:particle);
    [explodeParticle setType:0];//自機用パーティクル設定
    
    return explodeParticle;
}
-(DamageParticleView *)getDamageParticle{
    //dieしていれば爆発用particleは初期化されているはず=>描画用クラスで描画(self.view addSubview:particle);
    return damageParticle;
}


@end
