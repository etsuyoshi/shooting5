//
//  GameClassViewController.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/25.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//  敵機がランダムに動く中で、タップすると自機が移動、フリックさせるとビーム発射
//背景参考：http://dixq.net/rp/20.html


//アニメーションは以下の方が速いかもしれない。スムーズ(但し逐次位置は把握できない？)
//http://iphone-tora.sakura.ne.jp/uiview.html

/**
 ・敵機からビーム発射及び自機との接触イベント(敵機と自機の接触イベントも同じように出来れば尚よし)
 ・画面構成：一時停止ボタン：済(再開リアクション：済)、点数表示:済、機数(生き返り数)：ラベルはgradius5.jpg、パワーゲージ(自機耐久力＝死ににくいようにする必要、ビーム強力度)
 ・敵機にhitPoint：済、Beamにpowerを持たせて：済、当たった分だけダメージを与える：済、ダメージ発生時、簡単なparticleを表示：済
 ・敵機と衝突判定、衝突した後の生き返り時のリアクション(alpha修正により半透明にする)
 ・敵機倒した時にアイテムを生成：済、アイテムを精密に→CW
 ・敵機の描画を精密に？！→クラウドワークス
 ・画面タッチ時にビーム発射：済

 ・敵機をもっと頑丈に(typeによって爆発hit数を変更する)
 ・自機からのビームはタップ時常時発射:済
 ・自機の移動はpanGesture:済
 ・ハロワ編集
 ・信託記帳
 */

#import "GameClassViewController.h"
#import "EnemyClass.h"
#import "BeamClass.h"
#import "ItemClass.h"
#import "DWFParticleView.h"
#import "PowerGaugeClass.h"
#import "MyMachineClass.h"
#import <QuartzCore/QuartzCore.h>


CGRect rect_frame, rect_myMachine, rect_enemyBeam, rect_beam_launch;
UIImageView *iv_frame, *iv_myMachine, *iv_enemyBeam, *iv_beam_launch, *iv_background1, *iv_background2;


NSMutableArray *iv_arr_tokuten;
int y_background1, y_background2;
const int explosionCycle = 3;//爆発時間
int max_enemy_in_frame;
int x_frame, y_frame;
//int x_myMachine, x_enemyMachine, x_beam;
//int y_myMachine, y_enemyMachine, y_beam;
int size_machine;
int length_beam, thick_beam;//ビームの長さと太さ
Boolean isGameMode;
int center_x;
int myHitPoint;
int tokuten;

UIPanGestureRecognizer *flick_frame;
//UILongPressGestureRecognizer *longPress_frame;
Boolean isTouched;

MyMachineClass *MyMachine;
NSMutableArray *EnemyArray;
NSMutableArray *BeamArray;
NSMutableArray *ItemArray;

//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
//パワーゲージ背景：ビジュアルこだわりポイント
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
PowerGaugeClass *powerGauge;//imageviewを内包
UIImageView *iv_powerGauge;
UIImageView *iv_pg_ribrary;
UIImageView *iv_pg_circle;
UIImageView *iv_pg_cross;
int x_pg, y_pg, width_pg, height_pg;


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
    
    //UI編集：ナビゲーションボタンの追加＝一時停止
    
    UIBarButtonItem* right_button_stop = [[UIBarButtonItem alloc] initWithTitle:@"stop"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
//                                                                         action:@selector(alertView:clickedButtonAtIndex:)];
                               action:@selector(onClickedStopButton)];
    UIBarButtonItem* right_button_setting = [[UIBarButtonItem alloc]
                                          initWithTitle:@"set"
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                             action:@selector(onClickedSettingButton)];
    
    isGameMode = true;
    isTouched = false;
    self.navigationItem.rightBarButtonItems = @[right_button_stop, right_button_setting];
    self.navigationItem.leftItemsSupplementBackButton = YES; //戻るボタンを有効にする
    
    max_enemy_in_frame = 20;
    
    myHitPoint = 100;
    
    //タッチ用パネル(タップで自機移動、フリックでビーム発射するドリブン用パネル)
    rect_frame = [[UIScreen mainScreen] bounds];
    x_frame = rect_frame.size.width;
    y_frame = rect_frame.size.height;
    NSLog(@"%d, %d", x_frame, y_frame);
    iv_frame = [[UIImageView alloc]initWithFrame:rect_frame];
//    iv_frame.image =[UIImage imageNamed:@"gameover.png"];
    iv_frame.userInteractionEnabled = YES;
    flick_frame = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(onFlickedFrame:)];
    //LongPressGestureRecogを付けてしまうとtouchesEnded:メソッドが実行されないかも？
    //もしやるとしたら→http://teru2-bo2.blogspot.jp/2012/04/uilongpressgesturerecognizer.html
//    longPress_frame=
//        [[UILongPressGestureRecognizer alloc]initWithTarget:self
//                                                     action:@selector(onLongPressedFrame:)];
//    UITapGestureRecognizer *tap_frame = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                action:@selector(onTappedFrame:)];
    [iv_frame addGestureRecognizer:flick_frame];
//    [iv_frame addGestureRecognizer:longPress_frame];
    
//    [iv_frame addGestureRecognizer:tap_frame];
    [self.view bringSubviewToFront: iv_frame];//最前面に
    //ビューにメインイメージを貼り付ける
    [self.view addSubview:iv_frame];

    
    //backgroundの描画：絵を二枚用意して一枚目を表示して時間経過と共に進行方向(逆)にスクロールさせ、１枚目の終端を描画し始めたら２枚目の最初を描画させる
    iv_background1 = [[UIImageView alloc]initWithFrame:rect_frame];
    iv_background1.image = [UIImage imageNamed:@"cosmos_star4.png"];
    [self.view addSubview:iv_background1];//初期状態ではまず１枚目を描画させる
    y_background1 = 0;
    y_background2 = -rect_frame.size.height;

    
    length_beam = 20;
    thick_beam = 5;
    
    //敵の発生時の格納箱初期化
    EnemyArray = [[NSMutableArray alloc]init];
    
    //自機定義
    MyMachine = [[MyMachineClass alloc] init:x_frame/2 size:50];
    
    //自機が発射したビームを格納する配列初期化
    BeamArray = [[NSMutableArray alloc] init];
    
    //敵機を破壊した際のアイテム
    ItemArray = [[NSMutableArray alloc] init];
    
    
    //ここは時間がある時にtokutenオブジェクトとして保有しておく必要がある
    //点数表示用ImageView用配列
    iv_arr_tokuten = [[NSMutableArray alloc] init];
    //全て0で初期化
    int _strWidth = 25;
    int _strHeight = 36;
    int _x0 = 250;
    int _y0 = 20;
    int _maxKetasu = 4;
    for(int ketasu = 0 ; ketasu < _maxKetasu; ketasu++){
        
        UIImageView *_iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                                _y0,
                                                                                _strWidth - 1,
                                                                                _strHeight - 1)];
        _iv_tokuten.image = [UIImage imageNamed:@"zero.png"];
        [iv_arr_tokuten addObject:_iv_tokuten];
        [self.view addSubview:[iv_arr_tokuten objectAtIndex:ketasu]];
    }

    size_machine = 100;
    
    center_x = rect_frame.size.width/2 - size_machine/2;//画面サイズに対して中央になるように左位置特定
//    x_myMachine = center_x;//自機横位置は中心(ちなみにx_myMachineはイメージ画像の左端)
//    y_myMachine = 250;//自機縦位置
    
    
    count = 0;
    
    
    //パワーゲージの描画:新機種のframeサイズに応じて変える
    int devide_frame = 3;
    x_pg = rect_frame.size.width * (devide_frame - 1)/devide_frame;//左側１／４
    y_pg = rect_frame.size.height * (devide_frame - 1)/devide_frame;//下側１／４
    width_pg = MIN(x_pg / devide_frame, y_pg /devide_frame);
    height_pg = MIN(x_pg / devide_frame, y_pg /devide_frame);
    
    powerGauge = [[PowerGaugeClass alloc ]init:0 x_init:x_pg y_init:y_pg width:width_pg height:height_pg];
//    [powerGauge getImageView].transform = CGAffineTransformMakeRotation(2*M_PI* (float)(count-1)/60.0f );
    [self.view addSubview:[powerGauge getImageView]];
    
    //背景
    iv_powerGauge = [[UIImageView alloc]initWithFrame:CGRectMake(x_pg, y_pg, width_pg, height_pg)];//256bitx256bit
    iv_powerGauge.image = [UIImage imageNamed:@"powerGauge2.png"];
    iv_powerGauge.alpha = 0.1;
    [self.view addSubview:iv_powerGauge];


    iv_pg_ribrary = [[UIImageView alloc]initWithFrame:CGRectMake(x_pg, y_pg, width_pg, height_pg)];
    iv_pg_ribrary.image = [UIImage imageNamed:@"ribrary.png"];
    [self.view addSubview:iv_pg_ribrary];
    
    iv_pg_circle = [[UIImageView alloc]initWithFrame:CGRectMake(x_pg, y_pg, width_pg, height_pg)];
    iv_pg_circle.image = [UIImage imageNamed:@"circle_2w_rSmall_128.png"];
    [self.view addSubview:iv_pg_circle];

    
    iv_pg_cross = [[UIImageView alloc]initWithFrame:CGRectMake(x_pg, y_pg, width_pg, height_pg)];
    iv_pg_cross.image = [UIImage imageNamed:@"cross.png"];
    [self.view addSubview:iv_pg_cross];

    
    //以下実行後、0.1秒間隔でtimerメソッドが呼び出されるが、それと並行してこのメソッド(viewDidLoad)も実行される(マルチスレッドのような感じ)
    tm = [NSTimer scheduledTimerWithTimeInterval:0.1
                                          target:self
                                        selector:@selector(time:)//タイマー呼び出し
                                        userInfo:nil
                                         repeats:YES];
//    [self ordinaryAnimationStart];

}


- (void)ordinaryAnimationStart{
    //消去、生成、更新、表示
    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/前時刻の描画を消去_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
//    NSLog(@"count = %d", [EnemyArray count]);
    for(int i = 0;i < [EnemyArray count] ; i++){
//        NSLog(@"敵機 No:%d 消去[x = %d, y = %d]",
//              i,
//              [(EnemyClass *)[EnemyArray objectAtIndex:i] getX],
//              [(EnemyClass *)[EnemyArray objectAtIndex:i] getY]);
        [[(EnemyClass *)[EnemyArray objectAtIndex:i] getImageView ] removeFromSuperview];
//        NSLog(@"オブジェクト:%@",[(EnemyClass *)[EnemyArray objectAtIndex:i] getImageView]);
//        NSLog(@"aaa");
    }
    
    for(int i = 0; i < [BeamArray count] ;i++){
        [[(BeamClass *)[BeamArray objectAtIndex:i]getImageView] removeFromSuperview];
    }

    /////////////////////////////////////////////
//    if([iv_myMachine center].x >= x_myMachine && [iv_myMachine center].x < x_myMachine + size_machine){
//    
//    }else{
//        NSLog(@"x_past=%d, size=%d, x_now=%d", (int)[iv_myMachine center].x, size_machine, x_myMachine);
        [iv_myMachine removeFromSuperview];
    [[MyMachine getImageView] removeFromSuperview];
//    }
    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/生成_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
//    if([EnemyArray count] < 10){
        [self yieldEnemy];
//    }

    
    
    //自機
//    NSLog(@"自機");
    /*
    rect_myMachine = CGRectMake(x_myMachine, y_myMachine, size_machine, size_machine);//左上座標、幅、高さ
    NSMutableArray *_myImageList = [[NSMutableArray alloc] init];
    [_myImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"gradius00_stand_128.png"]]];
    [_myImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"gradius01_stand_128.png"]]];
    iv_myMachine = [[UIImageView alloc]initWithFrame:rect_myMachine];
    iv_myMachine.animationImages = _myImageList;
    iv_myMachine.animationDuration = 0.5;
    iv_myMachine.animationRepeatCount = 0;
     */
    
    
    //現状、自機と敵機をタップしても何も起こらないようにする
//    iv_myMachine.userInteractionEnabled = NO;
//    [iv_myMachine addGestureRecognizer:flick_frame];
    
    //ジェスチャーレコナイザーを付与して、タップイベントに備える
//    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//    [iv_myMachine addGestureRecognizer:panGesture];
//    UITapGestureRecognizer *tap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(onTappedMachine:)];
//    //タップ種類=シングルタップ
//    tap.numberOfTapsRequired = 1;
//    [iv_myMachine addGestureRecognizer:tap];
    //ビューにメインイメージを貼り付ける
    /*
    [self.view addSubview:iv_myMachine];
    [iv_myMachine startAnimating];
    */
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/進行_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    
    
    if([MyMachine getIsAlive]){
        
        [MyMachine doNext];//設定されたtype、x_loc,y_locプロパティでUIImageViewを作成する
        
        //ダメージパーティクルの消去
        [[MyMachine getDamageParticle] setIsEmitting:NO];
        
        //爆発から所定時間が経過しているか判定＝＞爆発パーティクルの消去
        if([MyMachine getDeadTime] >= explosionCycle){
            [[MyMachine getExplodeParticle] setIsEmitting:NO];//消去するには数秒後にNOに
        }
        
    }
    
    //敵機進行or爆発後のカウント
    for(int i = 0; i < [EnemyArray count] ; i++){
//        NSLog(@"do next at enemy:No %d", i);
        //既存敵機の距離進行！
        //dead状態になってからも、dead_timeが10未満の時までは更新doNextする(爆発パーティクル表示のため)
        if([(EnemyClass *)[EnemyArray objectAtIndex:i] getIsAlive] ||
           [(EnemyClass *)[EnemyArray objectAtIndex:i] getDeadTime] < explosionCycle){
            
            //更新(進行位置の更新と爆発後の時間経過)
            [(EnemyClass *)[EnemyArray objectAtIndex:i] doNext];
//            NSLog(@"%d番目敵：y=%d", i, [(EnemyClass *)[EnemyArray objectAtIndex:i] getY]);
            
            //ダメージパーティクルの消去
            [[(EnemyClass *)[EnemyArray objectAtIndex:i] getDamageParticle] setIsEmitting:NO];//消去するには数秒後にNOに
            
            //爆発してから時間が所定時間が経過してる場合
            if([(EnemyClass *)[EnemyArray objectAtIndex: i] getDeadTime] >= explosionCycle){
                //爆発パーティクルの消去
                NSLog(@"パーティクル消去 at %d", i);
                [[(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle] setIsEmitting:NO];//消去するには数秒後にNOに

            }
        }
    }
//    
//    //test:パーティクルのbirthRateがゼロになっているか
//    for(int i = 0;i < [EnemyArray count] ; i++){
//        if([[EnemyArray objectAtIndex:i] getIsAlive]){
//            NSLog(@"enemy[%d] is alive", i);
//        }else{
//            NSLog(@"enemy[%d] is dead ", i);
//            NSLog(@"enemy's dead_time is %d", [[EnemyArray objectAtIndex:i] getDeadTime]);
////            if([[EnemyArray objectAtIndex:i] getStatus]){
//            if([[[EnemyArray objectAtIndex:i] getParticle] getIsFinished]){
//                NSLog(@"enemy's explosion is finished");
//            }else{
//                NSLog(@"enemy's explosion is not finished");
//            }
//            
//        }
//    }
    
    
    
    
    //ビーム進行=>出来ればMyMachineの保有オブジェクトにする
    for(int i = 0; i < [BeamArray count] ; i++){
        if([(BeamClass *)[BeamArray objectAtIndex:i] getIsAlive]) {
            [(BeamClass *)[BeamArray objectAtIndex:i ] doNext];
        }
    }


//    NSLog(@"敵機配列");
    //表示
    for(int i = 0; i < [EnemyArray count] ; i++){
        if([(EnemyClass *)[EnemyArray objectAtIndex:i] getIsAlive]){
            //ビューにメインイメージを貼り付ける
            [self.view addSubview:[(EnemyClass *)[EnemyArray objectAtIndex:i] getImageView]];
            
        }
    }
    NSLog(@"%@", [MyMachine getImageView]);
    [self.view addSubview:[MyMachine getImageView]];
    
    
    ////////////////////ここまでMyMachineクラスの定義、動作完了。
    //続き＝＞x_myMachine、y・・・について、全て修正：前時刻の更新なのか、MyMachineクラスを更新するのか区別しておく必要あり。
    
    for(int i = 0; i < [BeamArray count] ; i++){
        if([(BeamClass *)[BeamArray objectAtIndex:i] getIsAlive]){
            //ビューにメインイメージを貼り付ける
            [self.view addSubview:[(BeamClass *)[BeamArray objectAtIndex:i] getImageView]];
        }

    }
    
    
    
    
    //アイテム取得判定
    for(int itemCount = 0; itemCount < [ItemArray count] ; itemCount++){
        ItemClass *_item = [ItemArray objectAtIndex:itemCount];
        if([_item getIsAlive]){//アイテムの獲得判定
            int _xItem = [_item getX];
            int _yItem = [_item getY];
            
//            if(
//               _xItem >= x_myMachine &&
//               _xItem <= x_myMachine + size_machine &&
//               _yItem >= y_myMachine &&
//               _yItem <= y_myMachine + size_machine){
//                
//                [[[ItemArray objectAtIndex:itemCount] getImageView] removeFromSuperview];
//                [[ItemArray objectAtIndex:itemCount] die];
//                
//                //得点の加算
//                tokuten++;
////                NSLog(@"tokuten = %d", tokuten);
//                [self displayTOKUTEN];
//                
//                //            break;
//                
//            }
            
            
            if(
               _xItem >= [MyMachine getX] &&
               _xItem <= [MyMachine getX] + [MyMachine getSize] &&
               _yItem >= [MyMachine getY] &&
               _yItem <= [MyMachine getY] + [MyMachine getSize]){
                
                [[[ItemArray objectAtIndex:itemCount] getImageView] removeFromSuperview];
                [[ItemArray objectAtIndex:itemCount] die];
                
                /*
                 _/_/_/_/_/_/_/_/_/_/_/_/
                 得点を加算
                 武器を強化
                 シールドを強化
                 体力回復？？
                 _/_/_/_/_/_/_/_/_/_/_/_/
                 */
                
                //得点の加算
                tokuten++;
                //                NSLog(@"tokuten = %d", tokuten);
                [self displayTOKUTEN];
                
                //            break;
                
            }
        }
    }
    
    
    
    //敵機の衝突判定:against自機＆ビーム
    for(int i = 0; i < [EnemyArray count] ;i++ ) {//全ての生存している敵に対して
//        NSLog(@"敵衝突判定:%d", i);
        
        if([(EnemyClass *)[EnemyArray objectAtIndex:i] getIsAlive]){//計算時間節約
            //                NSLog(@"敵衝突生存確認完了");
            
            EnemyClass *_enemy = (EnemyClass *)[EnemyArray objectAtIndex:i];
            
            
            
            //自機の衝突判定(判定対象は敵機、及び敵機ビーム)
//            if(
//               x_myMachine >= [_enemy getX] - [_enemy getSize] * 0.6 &&
//               x_myMachine <= [_enemy getX] + [_enemy getSize] * 0.6 &&
//               [_enemy getY] - [_enemy getSize] * 0 <= y_myMachine &&
//               [_enemy getY] + [_enemy getSize] * 0.5 >= y_myMachine){
//                
//                NSLog(@"自機と敵機との衝突");
//                
//                myHitPoint = MAX(0, myHitPoint-10);
//                
////                powerGauge = [[PowerGaugeClass alloc ]init:0 x_init:200 y_init:300 width:100 height:100];
////                [powerGauge getImageView].transform = CGAffineTransformMakeRotation(2*M_PI* count/60.0f );
//                [powerGauge setValue:myHitPoint];//仮で90とする
////                NSLog(@"hitpoint = %d", [powerGauge getValue]);
//                [self.view addSubview:[powerGauge getImageView]];
//            }
            
            
            if(
               [MyMachine getX] >= [_enemy getX] - [_enemy getSize] * 0.6 &&
               [MyMachine getX] <= [_enemy getX] + [_enemy getSize] * 0.6 &&
               [_enemy getY] - [_enemy getSize] * 0 <= [MyMachine getY] &&
               [_enemy getY] + [_enemy getSize] * 0.5 >= [MyMachine getY]){
                
                NSLog(@"自機と敵機との衝突");
                
                myHitPoint = MAX(0, myHitPoint-10);
                
                //                powerGauge = [[PowerGaugeClass alloc ]init:0 x_init:200 y_init:300 width:100 height:100];
                //                [powerGauge getImageView].transform = CGAffineTransformMakeRotation(2*M_PI* count/60.0f );
                [powerGauge setValue:myHitPoint];//仮で90とする
                //                NSLog(@"hitpoint = %d", [powerGauge getValue]);
                [self.view addSubview:[powerGauge getImageView]];
            }
            
            
            ////////////ここまで。
            
            
            for(int j = 0; j < [BeamArray count] ;j++){//発射した全てのビームに対して
                //                    NSLog(@"ビーム衝突判定:%d", j);
                if([(BeamClass *)[BeamArray objectAtIndex:j] getIsAlive]){
                    //                        NSLog(@"ビーム発射確認完了");
                    
                    int _xBeam = [(BeamClass *)[BeamArray objectAtIndex:j] getX];
                    int _yBeam = [(BeamClass *)[BeamArray objectAtIndex:j] getY];
                    if(
                       _xBeam >= [_enemy getX] - [_enemy getSize] * 0.6 &&
                       _xBeam <= [_enemy getX] + [_enemy getSize] * 0.6 &&
                       [_enemy getY] - [_enemy getSize] * 0 <= _yBeam &&
                       [_enemy getY] + [_enemy getSize] * 1>= _yBeam){
                        
                        
                        
                        NSLog(@"hit!!");
//                        NSLog(@"beam location[x = %d, y = %d], enemy location[x = %d, y = %d]",
//                              _xBeam, _yBeam, [_enemy getX], [_enemy getY]);
                        
                        //            bl_enemyAlive = false;
                        int damage = [[BeamArray objectAtIndex:j] getPower];
                        [(EnemyClass *)[EnemyArray objectAtIndex:i] setDamage:damage location:CGPointMake(_xBeam, _yBeam)];
                        
                        //上記setDamageでdieメソッドも包含実行
                        //                        [(EnemyClass *)[EnemyArray objectAtIndex:i] die:CGPointMake(_xBeam, _yBeam)];
                        
                        //                            [self drawBomb:(CGPointMake((float)_xBeam, (float)_yBeam))];

                        //ダメージパーティクル表示
                        [[(EnemyClass *)[EnemyArray objectAtIndex:i] getDamageParticle] setUserInteractionEnabled: NO];//インタラクション拒否
                        [[(EnemyClass *)[EnemyArray objectAtIndex:i] getDamageParticle] setIsEmitting:YES];//消去するには数秒後にNOに
                        [self.view bringSubviewToFront: [(EnemyClass *)[EnemyArray objectAtIndex:i] getDamageParticle]];//最前面に
                        [self.view addSubview: [(EnemyClass *)[EnemyArray objectAtIndex:i] getDamageParticle]];//表示する
                        
                        
                        
                        //爆発パーティクル
//                        NSLog(@"パーティクル = %@", [(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle]);
                        [[BeamArray objectAtIndex:j] die];//衝突したらビームは消去
                        
                        if(![[EnemyArray objectAtIndex:i] getIsAlive]){
                            NSLog(@"パーティクル = %@", [(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle]);
                            [[(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle] setUserInteractionEnabled: NO];//インタラクション拒否
                            [[(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle] setIsEmitting:YES];//消去するには数秒後にNOに
                            [self.view bringSubviewToFront: [(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle]];//最前面に
                            [self.view addSubview: [(EnemyClass *)[EnemyArray objectAtIndex:i] getExplodeParticle]];//表示する
                            
                            //アイテム出現
                            if(arc4random() % 2 == 0){
                                NSLog(@"アイテム出現");
                                ItemClass *_item = [[ItemClass alloc] init:_xBeam y_init:_yBeam width:20 height:20];
                                [ItemArray addObject:_item];
                                
                                [self.view bringSubviewToFront: [[ItemArray objectAtIndex:([ItemArray count]-1)] getImageView]];//最前面に
                                [self.view addSubview:[[ItemArray objectAtIndex:([ItemArray count]-1)] getImageView]];
                                
                                
                            }else{
                                NSLog(@"アイテムなし");
                            }

                        }
                        
                        break;//ビームループ脱出
                    }
                }
            }
        }
    }
    
    
    
    //powergaugeを回転させる
    [powerGauge setAngle:2*M_PI * count * 2/60.0f];
    
    //pg背景をアニメ
    [iv_powerGauge removeFromSuperview];
    int temp = count * 10  + 1;
    
    //透過度を0.1, 0.2, ・・, 1.0, 0.9, 0.8, ・・循環する。
    iv_powerGauge.alpha = 0.1 * MAX((temp - (int)(temp/10)*10)*((((int)(temp/10)) + 1) % 2) +//二桁目が偶数の場合
                                    ((((int)(temp/10)+1)*10-temp) *(((int)(temp/10)) % 2)//二桁目が奇数のとき
                                     ), 0.1);//0.1以上にする
//    NSLog(@"%f", 0.1 * (temp - (int)(temp/10)*10)*((((int)(temp/10)) + 1) % 2) +//二桁目が偶数の場合
//          ((((int)(temp/10)+1)*10-temp) *((int)(temp/10) % 2)));//二桁目が奇数の場合
    [self.view addSubview:iv_powerGauge];
    
    iv_pg_ribrary.transform = CGAffineTransformMakeRotation(-2*M_PI * count * 2/60.0f);
    
    
    
//    NSLog(@"%d, %d, 偶数 = %d, 奇数 = %d, 10の位 = %d", temp, (temp - (int)(temp/10)*10)*((((int)(temp/10)) + 1) % 2) +
//          ((((int)(temp/10)+1)*10-temp) *(((int)(temp/10)) % 2)),
//          (temp - (int)(temp/10)*10)*((((int)(temp/10)) + 1) % 2),
//          (((((int)(temp/10)+1)+1)*10-temp) *((int)(temp/10) % 2)),
//          (int)(temp/10));

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) handlePanGesture:(UIPanGestureRecognizer*) sender {
//    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) sender;
//    CGPoint location = [pan translationInView:self.view];
//    NSLog(@"pan x=%f, y=%f", location.x, location.y);
//}

- (void)time:(NSTimer*)timer{
    if(isGameMode){
        [self drawBackground];
        
        count += 0.1;
        
        
        //ここにあったdoNextをこのメソッドの敵機生成前に移行
//        NSLog(@"count");
        [self ordinaryAnimationStart];
        
        //一定時間経過するとゲームオーバー
        if(count >= 300){
            NSLog(@"gameover");
            //経過したらタイマー終了
            [tm invalidate];
            
            
            //ゲームオーバー表示
            CGRect rect_gameover = CGRectMake(50, 150, 250, 100);
            UIImageView *iv_gameover = [[UIImageView alloc]initWithFrame:rect_gameover];
            iv_gameover.image = [UIImage imageNamed:@"gameover.png"];
            [self.view addSubview:iv_gameover];
            
        }
        
        
        //ビームの更新作業
//        x_beam = x_myMachine + size_machine / 2;
//        y_beam -= length_beam;
        
        
        //    NSLog(@"after do next");
        
        //    if(count > 0.2){
        //        NSLog(@"ブレークポイント設置用：timer終了＝0.1秒経過");
        //    }else{
        //        NSLog(@"timer終了＝0.1秒経過");
        //    }
        

    }else{
        
        //一時停止ボタンが押された：isGameMode=false
        
        
        //停止中画面に移行(一時停止用UIImageViewの表示)
        
    }
}
//- (void)onLongPressedFrame:(UILongPressGestureRecognizer *)gr {
////    [self yieldBeam:0 init_x:(x_myMachine + size_machine/2) init_y:(y_myMachine - length_beam)];
//    NSLog(@"長押しがされました．");
////    isTouched = true;
//}

- (void)onFlickedFrame:(UIPanGestureRecognizer*)gr {
//    isTouched = true;
//    NSLog(@"onFlickedFrame");
    //参考：http://ultra-prism.jp/2012/12/01/uigesturerecognizer-touch-handling-sample/2/
//    http://www.yoheim.net/blog.php?q=20120620
    //フリックで移動した距離を取得する
    CGPoint point = [gr translationInView:self.view];
    CGPoint movedPoint = CGPointMake([MyMachine getX] + point.x, [MyMachine getY] + point.y);
    [MyMachine setX:movedPoint.x];
    [MyMachine setY:movedPoint.y];
    [gr setTranslation:CGPointZero inView:self.view];
    
//    [self yieldBeam:0 init_x:(x_myMachine + size_machine/2) init_y:(y_myMachine - length_beam)];
    
    // 指が移動したとき、上下方向にビューをスライドさせる
    if (gr.state == UIGestureRecognizerStateChanged) {//移動中
        isTouched = true;
//        NSLog(@"x = %d, y = %d", (int)[gr translationInView:self.view].x, (int)[gr translationInView:self.view].y);
        
        //フリックしている時は常に「自機位置から」ビームを発射：このメソッドではフリックと
//        [self yieldBeam:0 init_x:(x_myMachine + size_machine/2) init_y:(y_myMachine - length_beam)];

    }
    // 指が離されたとき、ビューを元に位置に戻して、ラベルの文字列を変更する
    else if (gr.state == UIGestureRecognizerStateEnded) {//指を離した時
        isTouched = false;
    }
}


//- (void)onTappedFrame:(UITapGestureRecognizer*)gr{
//    
//    //画面をタップした時
////    NSLog(@"tapped frame");
//    //横位置を取得する(取得したら自動的に呼び出されるordinaryAnimationStartによって画像もその位置に表示される)
//    CGPoint location = [gr locationInView:iv_frame];
////    NSLog(@"tapped main image@[ x = %f, y = %f]", location.x , location.y);
//    x_myMachine = location.x;
//    
//}


-(void) viewWillDisappear:(BOOL)animated {
    //navigationバーの戻るボタン押下時の呼び出しメソッド
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        NSLog(@"pressed back button");
        [tm invalidate];
    }
    [super viewWillDisappear:animated];
}


-(void) drawBomb:(CGPoint)location{
    
    
    //爆発テスト
//    CGRect rect_bomb = CGRectMake(location.x - bomb_size/2,
//                                  location.y - bomb_size/2,
//                                  bomb_size,bomb_size);
//    NSMutableArray *_bombImageList = [[NSMutableArray alloc] init];
//    
//    [_bombImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"bomb.png"]]];
////    [_bombImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"nothing32.png"]]];
//    [_bombImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"bomb_big.png"]]];
//    
//    UIImageView *iv_bomb = [[UIImageView alloc]initWithFrame:rect_bomb];
//    iv_bomb.animationImages = _bombImageList;
//    iv_bomb.animationDuration = 1.5;
//    iv_bomb.animationRepeatCount = 2;
//    //            iv_bomb.image = [UIImage imageNamed:@"bomb.png"];
//    [self.view addSubview:iv_bomb];
//    [iv_bomb startAnimating];

    
    
    
//
//    //爆発パーティクル
//    DWFParticleView *_fireView = [[DWFParticleView alloc] initWithFrame:CGRectMake(location.x, location.y, bomb_size, bomb_size)];
////    NSLog(@"location = x:%d, y:%d", (int)location.x, (int)location.y);
////    NSLog(@"DWFParticleView = object:::%@", _fireView);
//    [_fireView setUserInteractionEnabled: NO];//インタラクション拒否
//    [_fireView setIsEmitting:YES];//消去するには数秒後にNOに
//    [self.view bringSubviewToFront: _fireView];//最前面に
//    [self.view addSubview: _fireView];//表示する

}

-(void) yieldEnemy{
    //敵発生
//    NSLog(@"count = %d", [EnemyArray count]);
//    NSLog(@"%d", arc4random());
//    if(count == 0 || arc4random() % 4 == 0){
//    if(count == 0.5){
    if((int)(count * 10) % 5 ==0 && arc4random() % 2 == 0){
    
//        NSLog(@"生成");
//        EnemyClass *enemy = [[EnemyClass alloc]init:center_x size:50];
//        int x = (int)(count * 10) % 200;
//        int x = (int)(count * 100);// % 200;//arc4random() % 200;
        int x = arc4random() % 200;

        EnemyClass *enemy = [[EnemyClass alloc]init:x size:70];
        [EnemyArray addObject:enemy];//既に初期化済なので追加のみ
//        NSLog(@"敵機 新規生成, %d, %d", [enemy getY], (int)(count * 10));
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setSize:50 ];
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setX:center_x];
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setY:0];
    }


}

-(void)yieldBeam:(int)beam_type init_x:(int)x init_y:(int)y{
    //
    if(isTouched){
        BeamClass *beam = [[BeamClass alloc] init:x - size_machine/3 y_init:y + size_machine/2 width:50 height:50];
        [BeamArray addObject:beam];
    }
    
    
}

-(void)drawBackground{
    if(isTouched){
        [self yieldBeam:0 init_x:([MyMachine getX] + [MyMachine getSize]/2) init_y:([MyMachine getY] - length_beam)];
    }
    //frameの大きさと背景の現在描画位置を決定
    //点数オブジェクトで描画
//    NSLog(@"drawbackground : 1 = %d, 2 = %d", y_background1, y_background2);
    y_background1 += 5;
    y_background2 += 5;//スクロール速度
    
    
    if(y_background1 > rect_frame.size.height){
        y_background1 = -rect_frame.size.height;
    }else if(y_background2 > rect_frame.size.height){
        y_background2 = -rect_frame.size.height;
    }
    
    
    [iv_background1 removeFromSuperview];
    [iv_background2 removeFromSuperview];
    iv_background1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, y_background1,rect_frame.size.width,rect_frame.size.height + 5)];
    iv_background2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, y_background2,rect_frame.size.width,rect_frame.size.height + 5)];
    //宇宙空間の描画方法
    iv_background1.image = [UIImage imageNamed:@"cosmos_star4_repair.png"];
    iv_background2.image = [UIImage imageNamed:@"cosmos_star4_repair.png"];
//    iv_background1.alpha = 0.9;//透過率
//    iv_background2.alpha = 0.9;//透過率

    
    
    [self.view addSubview:iv_background1];
    [self.view addSubview:iv_background2];
    
    [self.view sendSubviewToBack:iv_background1];//最背面に表示
    [self.view sendSubviewToBack:iv_background2];
    
//    x_frame = rect_frame.size.width;
//    y_frame = rect_frame.size.height;
}

-(void)onClickedStopButton{
    NSLog(@"clicked stop button");
    isGameMode = false;
    
    [self displayStoppedFrame];
}

-(void)onClickedSettingButton{
    NSLog(@"clicked setting button");
    isGameMode = false;
    [self displaySettingFrame];
}

-(void)displayStoppedFrame{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PAUSE"
                                                    message:@"再開するにはボタンを押して下さい"
                                                   delegate:self//デリゲートによりボタン反応はalertViewメソッドに委ねられる
                                          cancelButtonTitle:@"ゲームに戻る"
                                          otherButtonTitles:nil
                            ,nil];
    [alert show];
    

}
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //１番目のボタンが押されたときの処理を記述する
            isGameMode = true;
            break;
//        case 1:
//            //２番目のボタンが押されたときの処理を記述する
//            NSLog(@"2");
//            break;
    }
    
}

-(void)displaySettingFrame{
    
}

-(void)displayTOKUTEN{
    
    int _strWidth = 25;
    int _strHeight = 36;
    int _x0 = 250;
    int _y0 = 20;
    int _maxKetasu = 4;
    
    
    NSString *moji = [ NSString stringWithFormat : @"%04d", tokuten];
//    NSLog(@"moji = %@", moji);
//    NSLog(@"moji at 0 = %@", [moji substringWithRange:NSMakeRange(0,1)]);//左一文字
    
    UIImageView *_iv_tokuten = nil;
    //４桁まで表示する
    for(int ketasu = 0; ketasu < _maxKetasu; ketasu++){
//        NSLog(@"moji at %d = %@", ketasu, [moji substringWithRange:NSMakeRange(ketasu,1)]);//左一文字
        [[iv_arr_tokuten objectAtIndex:ketasu] removeFromSuperview];//まずは前のスコアを非表示に。
    }
    
    [iv_arr_tokuten removeAllObjects];//次に配列内を全て空に。
    
    for(int ketasu = 0; ketasu < _maxKetasu; ketasu++){
        switch([[moji substringWithRange:NSMakeRange(ketasu, 1)] intValue]){
            case 0:
                
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth,
                                                                          _strHeight)];
                _iv_tokuten.image = [UIImage imageNamed:@"zero.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                
                break;
            case 1:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"one.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                break;
            case 2:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"two.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                break;
            case 3:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"three.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                break;
            case 4:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"four.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                break;
            case 5:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"five.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];

                break;
            case 6:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"six.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];

                break;
            case 7:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"seven.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];

                break;
            case 8:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"eight.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];

                break;
            case 9:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"nine.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];

                break;
        }
    }
    
}

//以下参考：http://www.atmarkit.co.jp/fsmart/articles/ios_sensor05/02.html

// 画面に指を一本以上タッチしたときに実行されるメソッド
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouched = true;
//    NSLog(@"touches count : %d (touchesBegan:withEvent:)", [touches count]);
}

// 画面に触れている指が一本以上移動したときに実行されるメソッド
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouched = true;
//    NSLog(@"touches count : %d (touchesMoved:withEvent:)", [touches count]);
}

// 指を一本以上画面から離したときに実行されるメソッド
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouched = false;
//    NSLog(@"touches count : %d (touchesEnded:withEvent:)", [touches count]);
}

// システムイベントがタッチイベントをキャンセルしたときに実行されるメソッド
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouched = false;
//    NSLog(@"touches count : %d (touchesCancelled:withEvent:)", [touches count]);
}
@end
