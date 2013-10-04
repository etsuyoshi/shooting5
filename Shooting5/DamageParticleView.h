//
//  DamageParticleView.h
//  Shooting4
//
//  Created by 遠藤 豪 on 13/10/02.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DamageParticleView : UIView{
    //    CAEmitterLayer *fireEmitter;
    CAEmitterLayer *particleEmitter;
    Boolean isFinished;
}

-(void)setIsEmitting:(BOOL)isEmitting;
-(Boolean)getIsFinished;



@end
