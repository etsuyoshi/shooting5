//
//  GameClassViewController.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/25.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//  敵機がランダムに動く中で、タップすると自機が移動、フリックさせるとビーム発射
//背景参考：http://dixq.net/rp/20.html

/**
 ・敵機からビーム発射及び自機との接触イベント(敵機と自機の接触イベントも同じように出来れば尚よし)
 ・画面構成：一時停止ボタン：済(再開リアクション：済)、点数表示、機数(生き返り数)、パワーゲージ(自機耐久力＝死ににくいようにする必要、ビーム強力度)
 ・行き帰り時のリアクション(alpha修正により半透明にする)
 ・敵機倒した時にアイテムを生成
 ・敵機の描画を精密に？！

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
#import <QuartzCore/QuartzCore.h>


CGRect rect_frame, rect_myMachine, rect_enemyBeam, rect_beam_launch;
UIImageView *iv_frame, *iv_myMachine, *iv_enemyBeam, *iv_beam_launch, *iv_background1, *iv_background2;

NSMutableArray *iv_arr_tokuten;
int y_background1, y_background2;
const int explosionCycle = 3;//爆発時間
Boolean bl_enemyAlive;
int max_enemy_in_frame;
int x_frame, y_frame;
int x_myMachine, x_enemyMachine, x_beam;
int y_myMachine, y_enemyMachine, y_beam;
int size_machine;
int length_beam, thick_beam;//ビームの長さと太さ
Boolean isGameMode;
int center_x;

int tokuten;



NSMutableArray *EnemyArray;
NSMutableArray *BeamArray;
NSMutableArray *ItemArray;

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
    self.navigationItem.rightBarButtonItems = @[right_button_stop, right_button_setting];
    self.navigationItem.leftItemsSupplementBackButton = YES; //戻るボタンを有効にする
    
    max_enemy_in_frame = 20;
    
    //敵の生存
    ////////////////////////////////////////////////////////////////
    bl_enemyAlive = true;//EnemyArray要素は既にinit内でaliveされている
    ////////////////////////////////////////////////////////////////
    
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
    x_myMachine = center_x;//自機横位置は中心
    y_myMachine = 300;//自機縦位置
    
    
    ////////////////////////////////////////////////////////////////
    x_enemyMachine = center_x;//敵機横位置は中心
    y_enemyMachine = 50;//敵機縦位置
    
    ////////////////////////////////////////////////////////////////
    
    
    
    
//    [self yieldEnemy];
    count = 0;
    
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
    NSLog(@"count = %d", [EnemyArray count]);
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
    [iv_myMachine removeFromSuperview];
    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/生成_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
//    if([EnemyArray count] < 3){
        [self yieldEnemy];
//    }

    
    
    //自機
    NSLog(@"自機");
    rect_myMachine = CGRectMake(x_myMachine, y_myMachine, size_machine, size_machine);//左上座標、幅、高さ
    NSMutableArray *_myImageList = [[NSMutableArray alloc] init];
    [_myImageList addObject:[UIImage imageNamed:[NSString stringWithFormat:@"gradius01_stand_128.png"]]];
    iv_myMachine = [[UIImageView alloc]initWithFrame:rect_myMachine];
    iv_myMachine.animationImages = _myImageList;
    iv_myMachine.animationDuration = 0.5;
    iv_myMachine.animationRepeatCount = 0;
    //現状、自機と敵機をタップしても何も起こらないようにする
    iv_myMachine.userInteractionEnabled = YES;
    
    //ジェスチャーレコナイザーを付与して、タップイベントに備える
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [iv_myMachine addGestureRecognizer:panGesture];
//    UITapGestureRecognizer *tap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(onTappedMachine:)];
//    //タップ種類=シングルタップ
//    tap.numberOfTapsRequired = 1;
//    [iv_myMachine addGestureRecognizer:tap];
    //ビューにメインイメージを貼り付ける
    [self.view addSubview:iv_myMachine];
    [iv_myMachine startAnimating];
    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/進行_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    
    
    //敵機進行or爆発後のカウント
    for(int i = 0; i < [EnemyArray count] ; i++){
        NSLog(@"do next at enemy:No %d", i);
        //既存敵機の距離進行！
        //dead状態になってからも、dead_timeが10未満の時までは更新doNextする(爆発パーティクル表示のため)
        if([(EnemyClass *)[EnemyArray objectAtIndex:i] getIsAlive] ||
           [(EnemyClass *)[EnemyArray objectAtIndex:i] getDeadTime] < explosionCycle){
            
            //更新(進行位置の更新と爆発後の時間経過)
            [(EnemyClass *)[EnemyArray objectAtIndex:i] doNext];
//            NSLog(@"%d番目敵：y=%d", i, [(EnemyClass *)[EnemyArray objectAtIndex:i] getY]);
            
            if([(EnemyClass *)[EnemyArray objectAtIndex: i] getDeadTime] >= explosionCycle){
                //爆発パーティクルの消去
                NSLog(@"パーティクル消去 at %d", i);
                [[(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle] setIsEmitting:NO];//消去するには数秒後にNOに
                //→最初のパーティクル以外は消去されていない？？

            }
        }
    }
    
    //test:パーティクルのbirthRateがゼロになっているか
    for(int i = 0;i < [EnemyArray count] ; i++){
        if([[EnemyArray objectAtIndex:i] getIsAlive]){
            NSLog(@"enemy[%d] is alive", i);
        }else{
            NSLog(@"enemy[%d] is dead ", i);
            NSLog(@"enemy's dead_time is %d", [[EnemyArray objectAtIndex:i] getDeadTime]);
//            if([[EnemyArray objectAtIndex:i] getStatus]){
            if([[[EnemyArray objectAtIndex:i] getParticle] getIsFinished]){
                NSLog(@"enemy's explosion is finished");
            }else{
                NSLog(@"enemy's explosion is not finished");
            }
            
        }
    }
    
    
    
    
    //ビーム進行
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
            
//            [[(EnemyClass *)[EnemyArray objectAtIndex:i] getImageView] removeFromSuperview];
            
//            NSLog(@"敵機 No:%d 表示[x = %d, y = %d]",i,
//                  [(EnemyClass *)[EnemyArray objectAtIndex:i] getX],
//                  [(EnemyClass *)[EnemyArray objectAtIndex:i] getY]);
        }
    }
    
    for(int i = 0; i < [BeamArray count] ; i++){
        if([(BeamClass *)[BeamArray objectAtIndex:i] getIsAlive]){
            //ビューにメインイメージを貼り付ける
            [self.view addSubview:[(BeamClass *)[BeamArray objectAtIndex:i] getImageView]];
        }

    }
    
    
    //ビーム進行
//    if(iv_myBeam != nil){//ビームが枠外に出るか敵に命中したらiv_myBeamをnilにする
//        rect_myBeam = CGRectMake(x_beam, y_beam, thick_beam, length_beam);
//        iv_myBeam = [[UIImageView alloc]initWithFrame:rect_myBeam];
//        iv_myBeam.image = [UIImage imageNamed:@"beam.png"];
//        [self.view addSubview:iv_myBeam];
        
        
        /*
        //ヒット処理
//        if((x_beam >= x_enemyMachine - size_machine/2 || x_beam <= x_enemyMachine + size_machine/2) &&
        if(bl_enemyAlive == true &&
           (x_beam >= x_enemyMachine && x_beam <= x_enemyMachine + size_machine) &&
           (y_enemyMachine <= y_beam) &&
           (y_enemyMachine + size_machine >= y_beam)){
            
            NSLog(@"hit!!");
            
            [self drawBomb:(CGPointMake((float)x_enemyMachine, (float)y_enemyMachine))];
            
            bl_enemyAlive = false;
            
               
        }
        */
    
        //自機の衝突判定(判定対象はアイテムと敵機、及び敵機ビーム)
    for(int itemCount = 0; itemCount < [ItemArray count] ; itemCount++){
        ItemClass *_item = [ItemArray objectAtIndex:itemCount];
        if([_item getIsAlive]){
            int _xItem = [_item getX];
            int _yItem = [_item getY];
            
            if(
               _xItem >= x_myMachine &&
               _xItem <= x_myMachine + size_machine &&
               _yItem >= y_myMachine &&
               _yItem <= y_myMachine + size_machine){
                
                [[[ItemArray objectAtIndex:itemCount] getImageView] removeFromSuperview];
                [[ItemArray objectAtIndex:itemCount] die];
                
                //得点の加算
                tokuten++;
                NSLog(@"tokuten = %d", tokuten);
                [self displayTOKUTEN];
                
                //            break;
                
            }

        }
    }
    
    //敵機のビーム衝突判定
    for(int i = 0; i < [EnemyArray count] ;i++ ) {//全ての生存している敵に対して
        NSLog(@"敵衝突判定:%d", i);
        
        if([(EnemyClass *)[EnemyArray objectAtIndex:i] getIsAlive]){//計算時間節約
            //                NSLog(@"敵衝突生存確認完了");
            
            EnemyClass *_enemy = (EnemyClass *)[EnemyArray objectAtIndex:i];
            
            for(int j = 0; j < [BeamArray count] ;j++){//発射した全てのビームに対して
                //                    NSLog(@"ビーム衝突判定:%d", j);
                if([(BeamClass *)[BeamArray objectAtIndex:j] getIsAlive]){
                    //                        NSLog(@"ビーム発射確認完了");
                    
                    int _xBeam = [(BeamClass *)[BeamArray objectAtIndex:j] getX];
                    int _yBeam = [(BeamClass *)[BeamArray objectAtIndex:j] getY];
                    if(
                       _xBeam >= [_enemy getX] &&
                       _xBeam <= [_enemy getX] + [_enemy getSize] &&
                       [_enemy getY] <= _yBeam &&
                       [_enemy getY] + [_enemy getSize] >= _yBeam){
                        
                        
                        
                        NSLog(@"hit!!");
                        NSLog(@"beam location[x = %d, y = %d], enemy location[x = %d, y = %d]",
                              _xBeam, _yBeam, [_enemy getX], [_enemy getY]);
                        
                        //            bl_enemyAlive = false;
                        [(EnemyClass *)[EnemyArray objectAtIndex:i] die:CGPointMake(_xBeam, _yBeam)];
                        
                        //                            [self drawBomb:(CGPointMake((float)_xBeam, (float)_yBeam))];
                        
                        //爆発パーティクル
                        NSLog(@"パーティクル = %@", [(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle]);
                        [[(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle] setUserInteractionEnabled: NO];//インタラクション拒否
                        [[(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle] setIsEmitting:YES];//消去するには数秒後にNOに
                        [self.view bringSubviewToFront: [(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle]];//最前面に
                        [self.view addSubview: [(EnemyClass *)[EnemyArray objectAtIndex:i] getParticle]];//表示する
                        
                        //アイテム出現
                        if(arc4random() % 2 == 0 || true){
                            NSLog(@"アイテム出現");
                            ItemClass *_item = [[ItemClass alloc] init:_xBeam y_init:_yBeam width:20 height:20];
                            [ItemArray addObject:_item];
                            
                            [self.view bringSubviewToFront: [[ItemArray objectAtIndex:([ItemArray count]-1)] getImageView]];//最前面に
                            [self.view addSubview:[[ItemArray objectAtIndex:([ItemArray count]-1)] getImageView]];
                            
                            
                        }else{
                            NSLog(@"アイテムなし");
                        }
                        
                        break;//ビームループ脱出
                    }
                }
            }
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

- (void) handlePanGesture:(UIPanGestureRecognizer*) sender {
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) sender;
    CGPoint location = [pan translationInView:self.view];
    NSLog(@"pan x=%f, y=%f", location.x, location.y);
}

- (void)time:(NSTimer*)timer{
    if(isGameMode){
        [self drawBackground];
        
        count += 0.1;
        
        //    srand(time(nil));
        //    int x_move = rand() % 50 - 25;
        //    int x_move = arc4random() % size_machine - size_machine / 2;
        int x_move = center_x * (sin(2 * M_PI * count * 50/ 360.0f) + 1.0f);
        //    x_enemyMachine = x_enemyMachine + x_move;
        x_enemyMachine = x_move;//正弦波の場合
        
        if (x_enemyMachine < 0){
            x_enemyMachine = size_machine * 2;
        }else if(x_enemyMachine > x_frame - size_machine){
            x_enemyMachine = x_frame - size_machine * 2;
        }
        
        //    y_enemyMachine += arc4random() % size_machine;
        
        
        //ここにあったdoNextをこのメソッドの敵機生成前に移行
        NSLog(@"count");
        [self ordinaryAnimationStart];
        
        //一定時間経過するとゲームオーバー
        if(count >= 30){
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
        x_beam = x_myMachine + size_machine / 2;
        y_beam -= length_beam;
        
        
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

- (void)onFlickedFrame:(UIPanGestureRecognizer*)gr {
//    NSLog(@"onFlickedFrame");
    //参考：http://ultra-prism.jp/2012/12/01/uigesturerecognizer-touch-handling-sample/2/
//    http://www.yoheim.net/blog.php?q=20120620
    //フリックで移動した距離を取得する
    CGPoint point = [gr translationInView:self.view];
    CGPoint movedPoint = CGPointMake(x_myMachine + point.x, y_myMachine + point.y);
    x_myMachine = movedPoint.x;
    y_myMachine = movedPoint.y;
    [gr setTranslation:CGPointZero inView:self.view];
    
    
    // 指が移動したとき、上下方向にビューをスライドさせる
    if (gr.state == UIGestureRecognizerStateChanged) {//移動中
     
//        NSLog(@"x = %d, y = %d", (int)[gr translationInView:self.view].x, (int)[gr translationInView:self.view].y);
        
        //フリックしている時は常に「自機位置から」ビームを発射：このメソッドではフリックと
        [self yieldBeam:0 init_x:(x_myMachine + size_machine/2) init_y:(y_myMachine - length_beam)];

    }
    // 指が離されたとき、ビューを元に位置に戻して、ラベルの文字列を変更する
    else if (gr.state == UIGestureRecognizerStateEnded) {//指を離した時
        
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
    if((int)(count * 10) % 10 ==0 && arc4random() % 2 == 0){
        
//        NSLog(@"生成");
//        EnemyClass *enemy = [[EnemyClass alloc]init:center_x size:50];
//        int x = (int)(count * 10) % 200;
        int x = arc4random() % 200;
        EnemyClass *enemy = [[EnemyClass alloc]init:x size:50];
        [EnemyArray addObject:enemy];//既に初期化済なので追加のみ
        NSLog(@"敵機 新規生成, %d, %d", [enemy getY], (int)(count * 10));
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setSize:50 ];
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setX:center_x];
//    [(EnemyClass *)[EnemyArray objectAtIndex:0] setY:0];
    }


}

-(void)yieldBeam:(int)beam_type init_x:(int)x init_y:(int)y{
    //
    BeamClass *beam = [[BeamClass alloc] init:x - size_machine/3 y_init:y + size_machine/2 width:50 height:50];
    [BeamArray addObject:beam];
    
    
}

-(void)drawBackground{
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
    iv_background1.image = [UIImage imageNamed:@"cosmos_star4.png"];
    iv_background2.image = [UIImage imageNamed:@"cosmos_star4.png"];
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
    NSLog(@"moji = %@", moji);
//    NSLog(@"moji at 0 = %@", [moji substringWithRange:NSMakeRange(0,1)]);//左一文字
    
    UIImageView *_iv_tokuten = nil;
    //４桁まで表示する
    for(int ketasu = 0; ketasu < _maxKetasu; ketasu++){
        NSLog(@"moji at %d = %@", ketasu, [moji substringWithRange:NSMakeRange(ketasu,1)]);//左一文字
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
                NSLog(@"%@", _iv_tokuten);
                
                break;
            case 1:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"one.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 2:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"two.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 3:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"three.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 4:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"four.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 5:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"five.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 6:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"six.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 7:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"seven.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 8:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"eight.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
            case 9:
                _iv_tokuten = [[UIImageView alloc]initWithFrame:CGRectMake(_x0 + (_strWidth - 10) * ketasu,
                                                                          _y0,
                                                                          _strWidth - 1,
                                                                          _strHeight - 1)];
                _iv_tokuten.image = [UIImage imageNamed:@"nine.png"];
                [iv_arr_tokuten addObject:_iv_tokuten];
                [self.view addSubview:[iv_arr_tokuten objectAtIndex:[iv_arr_tokuten count] - 1]];
                NSLog(@"%@", _iv_tokuten);
                break;
        }
    }
    
}
@end
