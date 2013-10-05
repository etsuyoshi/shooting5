//
//  ScoreBoardClass.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/05.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "ScoreBoardClass.h"

@implementation ScoreBoardClass



NSMutableArray *score_array;
int score;
int eachDigitWidth;
int eachDigitHeight;
int rightMargin;
int maxKetasu;
int xStart, yStart;
NSMutableArray *strEnglishNum;


-(id)init:(int)score x_init:(int)x_init y_init:(int)y_init{//端末自体のフレームの大きさを引数にした
    
    xStart = x_init;//frame.size.width - (rightMargin + eachDigitWidth * maxKetasu);//左端
    yStart = y_init;

    int overlap = 8;//イメージファイル同士の重なり幅(隣同士ぴったりにすると間が空きすぎるため)
    eachDigitWidth = 20;//各桁のimage幅は25px
    eachDigitHeight = 40;
//    rightMargin = 10;//右端の余白は10px
    strEnglishNum = [[NSMutableArray alloc]init];
    [strEnglishNum addObject:@"zero.png"];
    [strEnglishNum addObject:@"one.png"];
    [strEnglishNum addObject:@"two.png"];
    [strEnglishNum addObject:@"three.png"];
    [strEnglishNum addObject:@"four.png"];
    [strEnglishNum addObject:@"five.png"];
    [strEnglishNum addObject:@"six.png"];
    [strEnglishNum addObject:@"seven.png"];
    [strEnglishNum addObject:@"eight.png"];
    [strEnglishNum addObject:@"nine.png"];
    
    score_array = [[NSMutableArray alloc]init];
    maxKetasu = 4;
    
    for(int ketasu = 0;ketasu < maxKetasu;ketasu ++){
        UIImageView *_eachDigit = [[UIImageView alloc]initWithFrame:CGRectMake(xStart + (eachDigitWidth - overlap) * ketasu,
                                                                               yStart,
                                                                               eachDigitWidth,
                                                                               eachDigitHeight)];
        _eachDigit.image = [UIImage imageNamed:@"zero.png"];
        [score_array addObject:_eachDigit];
        
    }
    

    
    return self;
}

-(void)setScore:(int)_score{
    score = _score;
    
    

    NSString *moji = [ NSString stringWithFormat : @"%04d", score];//桁数によって変える必要がある。
    UIImageView *_eachDigit;
//    NSLog(@"start");
    for(int ketasu = 0; ketasu < maxKetasu; ketasu++){
//        NSLog(@"keta = %d", ketasu);
        for(int loopCount = 0; loopCount < [score_array count]; loopCount++){
//            NSLog(@"lc = %d, searchNum = %d", loopCount, [[moji substringWithRange:NSMakeRange(ketasu, 1)] intValue]);
            if(loopCount == [[moji substringWithRange:NSMakeRange(ketasu, 1)] intValue]){
                
//                _eachDigit = [[UIImageView alloc]initWithFrame:CGRectMake(xStart + (eachDigitWidth) * ketasu,
//                                                                          yStart,
//                                                                          eachDigitWidth,
//                                                                          eachDigitHeight)];
                _eachDigit.image = [UIImage imageNamed:[strEnglishNum objectAtIndex:loopCount]];
//                    [score_array addObject:_eachDigit];//追加してはだめ(二重ループで順番がめちゃくちゃなため)
                    [score_array replaceObjectAtIndex:ketasu withObject:_eachDigit];
                break;
            }
        }
    }
    
//    NSLog("finish");


}

-(int)getScore{
    return score;
}


-(NSMutableArray *)getImageViewArray{
    return score_array;
}

@end
