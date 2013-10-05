//
//  DWFParticleView.h
//  Shooting3
//
//  Created by 遠藤 豪 on 13/10/01.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DWFParticleView : UIView{
//    CAEmitterLayer *fireEmitter;
    CAEmitterLayer *particleEmitter;
    Boolean isFinished;
    int type;
}

//-(void)setEmitterPositionFromTouch: (UITouch*)t;
-(void)setIsEmitting:(BOOL)isEmitting;
-(Boolean)getIsFinished;
-(void)setType:(int)type;
//-(void)awakeFromNib:(CGPoint)location;
//-(void)bomb:(CGPoint)location;
@end
