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
        
        particleEmitter = (CAEmitterLayer *) self.layer;
        particleEmitter.emitterPosition = CGPointMake(0, 0);//CGPointMake(frame.origin.x, frame.origin.y);//CGPointMake(0, 0);
        particleEmitter.emitterSize = CGSizeMake(3,3);//frame.size.width, frame.size.height);
        particleEmitter.renderMode = kCAEmitterLayerAdditive;
        
        CAEmitterCell *particle = [CAEmitterCell emitterCell];
        particle.birthRate = 10;//火や水に見せるためには数百が必要
        particle.lifetime = 0.3;
        particle.lifetimeRange = 0.2;
        particle.color = [[UIColor colorWithRed: 0.8 green: 0.4 blue: 0.2 alpha: 0.1] CGColor];
        particle.contents = (id) [[UIImage imageNamed: @"star.png"] CGImage];
        particle.name = @"damage";
        particle.velocity = 10;
        particle.velocityRange = 20;
        particle.emissionRange = M_PI_2;
        particle.emissionLongitude = 0.025 * 180 / M_PI;
        particle.scaleSpeed = 0.5;
        particle.spin = 0.5;
        
        
        
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
