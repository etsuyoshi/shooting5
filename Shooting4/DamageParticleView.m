//
//  DamageParticleView.m
//  Shooting4
//
//  Created by 遠藤 豪 on 13/10/02.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "DamageParticleView.h"
#import "QuartzCore/QuartzCore.h"

@implementation DamageParticleView

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    isFinished = false;
    if (self) {
        // Initialization code
        //http://enharmonichq.com/tutorial-particle-systems-in-core-animation-with-caemitterlayer/
        particleEmitter = (CAEmitterLayer *) self.layer;
        particleEmitter.emitterPosition = CGPointMake(0, 0);//CGPointMake(frame.origin.x, frame.origin.y);//CGPointMake(0, 0);
        particleEmitter.emitterSize = CGSizeMake(3,3);//frame.size.width, frame.size.height);
        particleEmitter.renderMode = kCAEmitterLayerAdditive;
        
        CAEmitterCell *particle = [CAEmitterCell emitterCell];
        particle.birthRate = 100;//火や水に見せるためには数百が必要
        particle.lifetime = 0.5;//表示時間(秒)
        particle.lifetimeRange = 0;
        particle.color = [[UIColor colorWithRed: 0.1 green: 0.4 blue: 0.2 alpha: 0.5] CGColor];
//        particle.contents = (id) [[UIImage imageNamed: @"star.png"] CGImage];
        int pattern = arc4random() % 3;
        if(pattern == 0){
            particle.contents = (id) [[UIImage imageNamed: @"explode3.png"] CGImage];
        }else if(pattern == 1){
            particle.contents = (id) [[UIImage imageNamed: @"explode4.png"] CGImage];
        }else if(pattern == 2){
            particle.contents = (id) [[UIImage imageNamed: @"explode5.png"] CGImage];
        }
        particle.name = @"damage";
        particle.velocity = 10;//流れる平均速度(dot)
        particle.velocityRange = 10;//速度の標準偏差
        particle.emissionLongitude = -M_PI_2;//流れる方向(正：時計回り)
        particle.emissionRange = -1 * M_PI_2;//流れる方向の標準偏差
        particle.scale = 0.15f;//大きさ
        particle.scaleSpeed = 0.5f;
        particle.scaleRange = 1.0f;
        particle.spin = 1.0f;
        
        
        
        particleEmitter.emitterCells = [NSArray arrayWithObject: particle];
    }
    //    NSLog(@"%@", self);//<DWFParticleView: 0x92458e0; frame = (160 160; 150 150); layer = <CAEmitterLayer: 0x9243e50>>
    return self;
    
}


+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}



-(void)setIsEmitting:(BOOL)isEmitting
{
    //turn on/off the emitting of particles:引数がyesならばbirthRateを200に、noならば0(消去)
    //    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?200:0]
    //               forKeyPath:@"emitterCells.fire.birthRate"];
    if(isEmitting){
        isFinished = false;
    }else{
        isFinished = true;
    }
    
    
    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?100:0]
                   forKeyPath:@"emitterCells.damage.birthRate"];
    
    //    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?30:0] forKeyPath:@"emitterCells.particle.birthRate"];
}

-(Boolean)getIsFinished{
    return isFinished;
}


@end
