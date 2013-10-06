//
//  ItemClass.h
//  Shooting4
//
//  Created by 遠藤 豪 on 13/10/02.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemClass : NSObject{


int x_loc;
int y_loc;

int width;
int height;
Boolean isAlive;
UIImageView *iv;
CGRect rect;

}


-(id)init:(int)x_init y_init:(int)y width:(int)w height:(int)h;
-(id)init;

-(Boolean)getIsAlive;

//-(void)doNext;

-(void)die;
-(void)setLocation:(CGPoint)loc;
-(void)setX:(int)x;
-(void)setY:(int)y;

-(CGPoint)getLocation;
-(int) getX;
-(int) getY;
-(UIImageView *)getImageView;


@end
