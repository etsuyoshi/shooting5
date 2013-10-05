//
//  BeamClass.h
//  Shooting3
//
//  Created by 遠藤 豪 on 13/09/28.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeamClass : NSObject{
    
    
    int x_loc;
    int y_loc;
    int power;
    int width;
    int height;
    Boolean isAlive;
    UIImageView *iv;
    CGRect rect;
    
}


-(id)init:(int)x_init y_init:(int)y width:(int)w height:(int)h;
-(id)init;

-(Boolean)getIsAlive;

-(void)doNext;

-(void)die;
-(void)setLocation:(CGPoint)loc;
-(void)setX:(int)x;
-(void)setY:(int)y;

-(int)getPower;
-(CGPoint)getLocation;
-(int) getX;
-(int) getY;
-(int)getSize;
-(UIImageView *)getImageView;

@end
