//
//  GameClassViewController.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/25.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//  敵機がランダムに動く中で、タップすると自機が移動、フリックさせるとビーム発射
//

#import "GameClassViewController.h"


CGRect rect_frame, rect_myMachine, rect_enemyMachine, rect_myBeam, rect_enemyBeam, rect_beam_launch;
UIImageView *iv_frame, *iv_myMachine, *iv_enemyMachine, *iv_myBeam, *iv_enemyBeam, *iv_beam_launch;

int x_frame, y_frame;
int x_myMachine, x_enemyMachine, x_beam;
int y_myMachine, y_enemyMachine, y_beam;
int size_machine;
int length_beam, thick_beam;//ビームの長さと太さ

int center_x;
int beam_time;

NSTimer *tm;
float count = 0;

@interface GameClassViewController ()

@end

@implementation GameClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //タッチ用パネル(タップで自機移動、フリックでビーム発射するドリブン用パネル)
    rect_frame = [[UIScreen mainScreen] bounds];
    x_frame = rect_frame.size.width;
    y_frame = rect_frame.size.height;
    NSLog(@"%d, %d", x_frame, y_frame);
    iv_frame = [[UIImageView alloc]initWithFrame:rect_frame];
//    iv_frame.image =[UIImage imageNamed:@"gameover.png"];
    iv_frame.userInteractionEnabled = YES;
    UIPanGestureRecognizer *flick_frame = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onFlickedFrame:)];
    UITapGestureRecognizer *tap_frame = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(onTappedFrame:)];
    [iv_frame addGestureRecognizer:flick_frame];
    [iv_frame addGestureRecognizer:tap_frame];
    //ビューにメインイメージを貼り付ける
    [self.view addSubview:iv_frame];
    
    
    length_beam = 50;
    thick_beam = 5;
    

    size_machine = 30;
    center_x = rect_frame.size.width/2 - size_machine/2;//画面サイズに対して中央になるように左位置特定
    x_myMachine = center_x;//自機横位置は中心
    y_myMachine = 300;//自機縦位置
    x_enemyMachine = center_x;//敵機横位置は中心
    y_enemyMachine = 50;//敵機縦位置
    iv_myBeam = nil;//ビームは初期状態でnil
    
    count = 0;
    tm = [NSTimer scheduledTimerWithTimeInterval:0.1
                                          target:self
                                        selector:@selector(time:)//タイマー呼び出し
                                        userInfo:nil
                                         repeats:YES];
    

    [self ordinaryAnimationStart];
}


- (void)ordinaryAnimationStart{
    //位置と大きさ(時々刻々変わるのでviewdidloadではなくここに記述)
    rect_myMachine = CGRectMake(x_myMachine, y_myMachine, size_machine, size_machine);//左上座標、幅、高さ
    rect_enemyMachine = CGRectMake(x_enemyMachine, y_enemyMachine, size_machine, size_machine);
    //    NSLog(@"x = %d, y = %d", _center_x, _myMachine_y);
    iv_myMachine = [[UIImageView alloc]initWithFrame:rect_myMachine];
    iv_enemyMachine = [[UIImageView alloc]initWithFrame:rect_enemyMachine];
    //現状、自機と敵機をタップしても何も起こらないようにする
//    iv_myMachine.userInteractionEnabled = YES;
//    iv_enemyMachine.userInteractionEnabled = YES;

    
    NSMutableArray *_myImageList = [[NSMutableArray alloc] init];
    [_myImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"flight.png"]]];
    //    [imageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"standard3.png"]]];
//    [_imageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"enemy.png"]]];
    
    //自機
    iv_myMachine.animationImages = _myImageList;
    iv_myMachine.animationDuration = 0.5;
    iv_myMachine.animationRepeatCount = 0;
    //ジェスチャーレコナイザーを付与して、タップイベントに備える
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(onTappedMachine:)];
    //タップ種類=シングルタップ
    tap.numberOfTapsRequired = 1;
    [iv_myMachine addGestureRecognizer:tap];
    //ビューにメインイメージを貼り付ける
    [self.view addSubview:iv_myMachine];
    [iv_myMachine startAnimating];
    
    
    //敵機
    NSMutableArray *_enemyImageList = [[NSMutableArray alloc] init];
    [_enemyImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"enemy.png"]]];
    iv_enemyMachine.animationImages = _enemyImageList;
    iv_enemyMachine.animationDuration = 0.5;
    iv_enemyMachine.animationRepeatCount = 0;
    //タップ種類=シングルタップ
    tap.numberOfTapsRequired = 1;
    [iv_enemyMachine addGestureRecognizer:tap];
    //ビューにメインイメージを貼り付ける
    [self.view addSubview:iv_enemyMachine];
    [iv_enemyMachine startAnimating];
    
    
    //ビーム進行
    [iv_myBeam removeFromSuperview];
    if(iv_myBeam != nil){//ビームが枠外に出るか敵に命中したらiv_myBeamをnilにする
        [iv_myBeam removeFromSuperview];
        rect_myBeam = CGRectMake(x_beam, y_beam, thick_beam, length_beam);
        iv_myBeam = [[UIImageView alloc]initWithFrame:rect_myBeam];
        iv_myBeam.image = [UIImage imageNamed:@"beam.png"];
        [self.view addSubview:iv_myBeam];
        x_beam = x_myMachine + size_machine / 2;
        y_beam -= length_beam;
        
        if(y_beam < - length_beam){
            
            [iv_myBeam removeFromSuperview];
            iv_myBeam = nil;
        }
    }
    
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//メインイメージをタップした時に起動
- (void)onTappedMachine:(UITapGestureRecognizer*)gr{
    
    //タップされた位置座標を取得する(左上端からの座標値を取得)
    CGPoint location = [gr locationInView:iv_myMachine];
    NSLog(@"tapped main image@[ x = %f, y = %f]", location.x , location.y);
    
    //ジェスチャーの種類：http://blog.syuhari.jp/archives/2234
    
    
}

- (void)time:(NSTimer*)timer{
    count += 0.1;
    
    //前時刻の描画を消去
    [iv_enemyMachine removeFromSuperview];
    [iv_myMachine removeFromSuperview];
//    [iv_beam_launch removeFromSuperview];
    
    
//    NSLog(@"time:%f", count);
    //タイマーが有効かどうか
    //    NSString *str = [tm isValid] ? @"yes" : @"no";
    //    NSLog(@"isValid:%@", str);
    srand(time(nil));
//    int x_move = rand() % 50 - 25;
//    int x_move = arc4random() % size_machine - size_machine / 2;
    int x_move = center_x * (sin(2 * M_PI * count * 50/ 360.0f) + 1.0f);
//    NSLog(@"%f", sin(2 * M_PI * count * 50/ 360.0f)/2.0f);
//    NSLog(@"x_move = %d", x_move);
//    x_enemyMachine = x_enemyMachine + x_move;
    x_enemyMachine = x_move;//正弦波の場合
    if (x_enemyMachine < 0){
        x_enemyMachine = size_machine * 2;
    }else if(x_enemyMachine > x_frame - size_machine){
        x_enemyMachine = x_frame - size_machine * 2;
    }
//    NSLog(@"x_enemy = %d", x_enemyMachine);
    [self ordinaryAnimationStart];
    
    //一定時間経過するとゲームオーバー
    if(count >=150){
        NSLog(@"gameover");
        //３秒経過したらタイマー終了
        [tm invalidate];
        
        
        //ゲームオーバー表示
        CGRect rect_gameover = CGRectMake(50, 150, 250, 100);
        UIImageView *iv_gameover = [[UIImageView alloc]initWithFrame:rect_gameover];
        iv_gameover.image = [UIImage imageNamed:@"gameover.png"];
        [self.view addSubview:iv_gameover];
        
    }
}

- (void)onFlickedFrame:(UIPanGestureRecognizer*)gr {
//    NSLog(@"onFlickedFrame");
    //参考：http://ultra-prism.jp/2012/12/01/uigesturerecognizer-touch-handling-sample/2/
    //フリックで移動した距離を取得する
    CGPoint point = [gr translationInView:self.view];
    
    // 指が移動したとき、上下方向にビューをスライドさせる
    if (gr.state == UIGestureRecognizerStateChanged) {//移動中
//        CGPoint newPoint = _center;
//        newPoint.y += point.y;
//        self.view.center = newPoint;
    }
    // 指が離されたとき、ビューを元に位置に戻して、ラベルの文字列を変更する
    else if (gr.state == UIGestureRecognizerStateEnded) {//指を離した時
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveLinear animations:^{
//            self.view.center = _center;
//        } completion:^(BOOL finished) {
//        }];
        
        if (point.y < 0) {//上向き
            
            if(iv_myBeam == nil){
                NSLog(@"beam!!");
                
                //ビーム発射=>最終的には煙幕のようなものを出す
                rect_beam_launch = CGRectMake(x_myMachine + size_machine / 2,
                                              y_myMachine - length_beam,
                                              thick_beam,
                                              length_beam);
                iv_beam_launch = [[UIImageView alloc]initWithFrame:rect_beam_launch];
                NSMutableArray *_beamImageList = [[NSMutableArray alloc] init];
                [_beamImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"beam.png"]]];
                [_beamImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"nothing32.png"]]];
                //            iv_beam_launch = [[UIImageView alloc]initWithFrame:rect_beam_launch];
                iv_beam_launch.animationImages = _beamImageList;
                iv_beam_launch.animationDuration = 0.5;//0.5秒間隔でアニメーション
                iv_beam_launch.animationRepeatCount = 3;//切り替え回数
                [self.view addSubview:iv_beam_launch];
                NSLog(@"%@", self);
                [iv_beam_launch startAnimating];
                
                
                
                //ビーム進行
                x_beam = x_myMachine + size_machine / 2;
                y_beam = y_myMachine - length_beam,
                rect_myBeam = CGRectMake(x_beam,
                                         y_beam,
                                         thick_beam,
                                         length_beam);
                iv_myBeam = [[UIImageView alloc]initWithFrame:rect_myBeam];
                iv_myBeam.image = [UIImage imageNamed:@"beam.png"];
                [self.view addSubview:iv_myBeam];
                
                
                beam_time = 0;

            }else{
                NSLog(@"%@", iv_myBeam);
            }
        }
        else {//下向き
            NSLog(@"back");
        }
    }
}


- (void)onTappedFrame:(UITapGestureRecognizer*)gr{
    
    //画面をタップした時
//    NSLog(@"tapped frame");
    //横位置を取得する(取得したら自動的に呼び出されるordinaryAnimationStartによって画像もその位置に表示される)
    CGPoint location = [gr locationInView:iv_frame];
//    NSLog(@"tapped main image@[ x = %f, y = %f]", location.x , location.y);
    x_myMachine = location.x;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        NSLog(@"pressed back button");
        [tm invalidate];
    }
    [super viewWillDisappear:animated];
}
@end
