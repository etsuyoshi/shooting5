//
//  PowerGaugeClass.h
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/03.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerGaugeClass : NSObject{
    int value;
    UIImageView *iv_gauge;
    double angle;
}

-(id)init:(int)type x_init:(int)x y_init:(int)y width:(int)w height:(int)h;
-(void)setValue:(int)_value;
-(int)getValue;
-(UIImageView *)getImageView;
-(void)setAngle:(double)angle;
-(double)getAngle;
@end
