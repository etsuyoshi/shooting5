//
//  DWFParticleView.m
//  Shooting3
//
//  Created by 遠藤 豪 on 13/10/01.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "DWFParticleView.h"
#import "QuartzCore/QuartzCore.h"

@implementation DWFParticleView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    isFinished = false;
    if (self) {
        // Initialization code
        
        particleEmitter = (CAEmitterLayer *) self.layer;
        particleEmitter.emitterPosition = CGPointMake(0, 0);//CGPointMake(frame.origin.x, frame.origin.y);//CGPointMake(0, 0);
        particleEmitter.emitterSize = CGSizeMake(frame.size.width, frame.size.height);
        particleEmitter.renderMode = kCAEmitterLayerAdditive;
        
        CAEmitterCell *particle = [CAEmitterCell emitterCell];
        particle.birthRate = 300;//火や水に見せるためには数百が必要
        particle.lifetime = 2.0;
        particle.lifetimeRange = 1.5;
        particle.color = [[UIColor colorWithRed: 0.2 green: 0.4 blue: 0.8 alpha: 0.1] CGColor];
        particle.contents = (id) [[UIImage imageNamed: @"Particles_fire.png"] CGImage];
        particle.name = @"fire";
        particle.velocity = 50;
        particle.velocityRange = 20;
        particle.emissionLongitude = M_PI_2;
        particle.emissionRange = M_PI_2;
        particle.scale = 0.3f;
        particle.scaleRange = 0;
        particle.scaleSpeed = 0.5;
        particle.spin = 0.5;

        particleEmitter.emitterCells = [NSArray arrayWithObject: particle];
    }
//    NSLog(@"%@", self);//<DWFParticleView: 0x92458e0; frame = (160 160; 150 150); layer = <CAEmitterLayer: 0x9243e50>>
    return self;

    
    
    
}

//-(void)awakeFromOther:(CGPoint)location{
//    [self awakeFromNib];
//    fireEmitter.emitterPosition = location;
//    
//}

+ (Class) layerClass //3
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

/*
-(void)setEmitterPositionFromTouch: (UITouch*)t
{
    //change the emitter's position
    fireEmitter.emitterPosition = [t locationInView:self];
}
*/

-(void)setType:(int)_type{
    type = _type;
    
    switch(type){
        case 0://自機は赤で前向き
//            NSLog(@"explode at type = %d", type);
            [particleEmitter setValue:(id)[[UIColor colorWithRed: 0.5 green: 0.1 blue: 0.1 alpha: 0.1] CGColor]
                           forKeyPath:@"emitterCells.fire.color"];
            [particleEmitter setValue:[NSNumber numberWithDouble:-M_PI_2]
                           forKeyPath:@"emitterCells.fire.emissionLongitude"];
            break;
        case 1://敵機は青で後ろ向き
//            NSLog(@"explode at type = %d", type);
            [particleEmitter setValue:(id)[[UIColor colorWithRed: 0.1 green: 0.1 blue: 0.5 alpha: 0.1] CGColor]
                           forKeyPath:@"emitterCells.fire.color"];
            [particleEmitter setValue:[NSNumber numberWithDouble:M_PI_2]
                           forKeyPath:@"emitterCells.fire.emissionLongitude"];

            break;
    }
    

    
    
    
    
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
                   forKeyPath:@"emitterCells.fire.birthRate"];

//    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?30:0] forKeyPath:@"emitterCells.particle.birthRate"];
}

-(Boolean)getIsFinished{
    return isFinished;
}


@end
