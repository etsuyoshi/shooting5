//
//  EnemyClass.h
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/26.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnemyClass : NSObject


-(void)setLocation:(CGPoint)loc;
-(void)setX:(int)x;
-(void)setY:(int)y;

-(CGPoint) getLocation;
-(int) getX;
-(int) getY;
@end
