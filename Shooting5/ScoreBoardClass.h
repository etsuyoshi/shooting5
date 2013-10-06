//
//  ScoreBoardClass.h
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/05.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreBoardClass : NSObject{
    int score;
    int eachDigitWidth;
    int eachDigitHeight;
    int rightMargin;
    int maxKetasu;
    int xStart, yStart;
    NSMutableArray *strEnglishNum;
    NSMutableArray *score_array;
}

-(id)init:(int)type x_init:(int)x_init y_init:(int)y_init;
-(NSMutableArray *)getImageViewArray;
-(void)setScore:(int)_score;
-(int)getScore;
@end
