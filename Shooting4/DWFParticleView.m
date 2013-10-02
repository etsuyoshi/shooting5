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
    /*
    self = [super initWithFrame:frame];
    
    if(self){
        NSLog(@"bomb start!!");
        //set ref to the layer
        fireEmitter = (CAEmitterLayer*)self.layer; //2
        
        //configure the emitter layer
        //    fireEmitter.emitterPosition = CGPointMake(50, 50);
        fireEmitter.emitterPosition = CGPointMake(frame.origin.x, frame.origin.y);
        fireEmitter.emitterSize = CGSizeMake(10, 10);
        
        fireEmitter.renderMode = kCAEmitterLayerAdditive;
        
        
        CAEmitterCell* fire = [CAEmitterCell emitterCell];
        //    fire.birthRate = 200;
        fire.birthRate = 200;
        fire.lifetime = 2.0;
        fire.lifetimeRange = 0.5;
        fire.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
        fire.contents = (id)[[UIImage imageNamed:@"Particles_fire.png"] CGImage];
        
        
        fire.velocity = 10;
        fire.velocityRange = 20;
        fire.emissionRange = M_PI_2 * 2;
        
        
        [fire setName:@"fire"];
        
        fire.scaleSpeed = 0.1;//広がる速さ
        //    fire.spin = 0.5;//回転
        
        //add the cell to the layer and we're done
        fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
        
    }
    NSLog(@"%@", self);//<DWFParticleView: 0x7568ec0; frame = (74 80; 150 150); layer = <CAEmitterLayer: 0x759cfc0>>
    return self;
    */
    
    self = [super initWithFrame:frame];
    isFinished = false;
    if (self) {
        // Initialization code
        
        particleEmitter = (CAEmitterLayer *) self.layer;
        particleEmitter.emitterPosition = CGPointMake(0, 0);//CGPointMake(frame.origin.x, frame.origin.y);//CGPointMake(0, 0);
        particleEmitter.emitterSize = CGSizeMake(frame.size.width, frame.size.height);
        particleEmitter.renderMode = kCAEmitterLayerAdditive;
        
        CAEmitterCell *particle = [CAEmitterCell emitterCell];
        particle.birthRate = 30;//火や水に見せるためには数百が必要
        particle.lifetime = 1.0;
        particle.lifetimeRange = 1.5;
        particle.color = [[UIColor colorWithRed: 0.2 green: 0.4 blue: 0.8 alpha: 0.1] CGColor];
        particle.contents = (id) [[UIImage imageNamed: @"Particles_fire.png"] CGImage];
        particle.name = @"particle";
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
    
    
    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?30:0]
                   forKeyPath:@"emitterCells.particle.birthRate"];

//    [particleEmitter setValue:[NSNumber numberWithInt:isEmitting?30:0] forKeyPath:@"emitterCells.particle.birthRate"];
}

-(Boolean)getIsFinished{
    return isFinished;
}


@end
