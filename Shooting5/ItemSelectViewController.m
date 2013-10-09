//
//  ItemSelectViewController.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/07.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "ItemSelectViewController.h"
#import "GameClassViewController.h"
#import <QuartzCore/QuartzCore.h>

//#define COMPONENT_00 0
//#define COMPONENT_01 1
//#define COMPONENT_02 2
//#define COMPONENT_03 3
//#define COMPONENT_04 4
//#define COMPONENT_05 5
//#define COMPONENT_06 6
//#define COMPONENT_07 7
//#define COMPONENT_08 8
//#define COMPONENT_09 9
//#define COMPONENT_10 10

#define MARGIN_CENTER_UPPER_COMPONENT 10
#define Y_MOST_UPPER_COMPONENT 30
#define W_MOST_UPPER_COMPONENT 130
#define H_MOST_UPPER_COMPONENT 50

#define MARGIN_UPPER_TO_RANKING 2

#define W_RANKING_COMPONENT 300
#define H_RANKING_COMPONENT 240

#define MARGIN_RANKING_TO_FORMAL_BUTTON 2

#define SIZE_FORMAL_BUTTON 50
#define INTERVAL_FORMAL_BUTTON 1

#define MARGIN_FORMAL_TO_START 2

#define W_BT_START 150
#define H_BT_START 50

#define ALPHA_COMPONENT 0.5

NSMutableArray *imageFileArray;
NSMutableArray *tagArray;

UIView *subView;
UIButton *closeButton;//閉じるボタン
@interface ItemSelectViewController ()

@end

//コンポーネント動的配置：http://d.hatena.ne.jp/mohayonao/20100719/1279524706
@implementation ItemSelectViewController

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
    
//    imageFile = [[NSMutableArray alloc]init];
//    _imageFile = [NSArray arrayWithObjects:@"red.png", @"blue_item_yuri_big.png", nil];
    imageFileArray = [NSArray arrayWithObjects:
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
//                       @"red.png",
//                       @"red.png",
//                       @"blue_item_yuri_big2.png",
//                       @"yellow_item_thunder.png",
                       nil],
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
//                       @"red.png",
//                       @"yellow_item_thunder.png",
//                       @"red.png",
                       nil],
                      /*
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
//                       @"red.png",
//                       @"yellow_item_thunder.png",
//                       @"red.png",
                       nil],
                      
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
                       @"blue_item_yuri_big2.png",
//                       @"red.png",
//                       @"yellow_item_thunder.png",
//                       @"red.png",
                       nil],
                       */
                      nil];
//    NSLog(@"imageFileArray initialization complete");
    
    tagArray = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"200", @"201", @"202", @"203", nil],
                [NSArray arrayWithObjects:@"210", @"211", @"212", @"213", nil],
                [NSArray arrayWithObjects:@"220", @"221", @"222", @"223", nil],
                [NSArray arrayWithObjects:@"230", @"231", @"232", @"233", nil],
                nil];
//    NSLog(@"tagArray initialization complete");

	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{

//    NSLog(@"init select view controller start!!");
    int x_frame_center = (int)[[UIScreen mainScreen] bounds].size.width/2;
//    NSLog(@"%d" , x_frame_center);
//    int y_frame_center = (int)[[UIScreen mainScreen] bounds].size.height/2;//使用しない？
//    NSLog(@"中心＝%d", (int)[[UIScreen mainScreen] bounds].origin.x);
    
    //背景作成
    UIImageView *iv_back = [self createImageView:@"chara_test2.png" tag:0 frame:[[UIScreen mainScreen] bounds]];
    iv_back.alpha = ALPHA_COMPONENT;
    [self.view sendSubviewToBack:iv_back];
    [self.view addSubview:iv_back];
    
    //最高得点表示部分
    UIImageView *iv_tokuten = [self createImageView:@"white_128.png"
                                                tag:100
                                              frame:CGRectMake(x_frame_center - MARGIN_CENTER_UPPER_COMPONENT - W_MOST_UPPER_COMPONENT,
                                                               Y_MOST_UPPER_COMPONENT,
                                                               W_MOST_UPPER_COMPONENT,
                                                               H_MOST_UPPER_COMPONENT)];
    iv_tokuten.alpha = ALPHA_COMPONENT;
    [[iv_tokuten layer] setCornerRadius:10.0];
    [iv_tokuten setClipsToBounds:YES];
    [self.view addSubview:iv_tokuten];
    
    
    
    //獲得コイン数表示部分
    UIImageView *iv_coin = [self createImageView:@"white_128.png"
                                             tag:101
                                           frame:CGRectMake(x_frame_center + MARGIN_CENTER_UPPER_COMPONENT,
                                                            Y_MOST_UPPER_COMPONENT,
                                                            W_MOST_UPPER_COMPONENT,
                                                            H_MOST_UPPER_COMPONENT)];
    
    iv_coin.alpha = ALPHA_COMPONENT;
    [[iv_coin layer] setCornerRadius:10.0];
    [iv_coin setClipsToBounds:YES];
    [self.view addSubview:iv_coin];
    
    
    
    
    //ランキング表示部分
    UIImageView *iv_ranking = [self createImageView:@"black_128.png"
                                             tag:103
                                           frame:CGRectMake(x_frame_center - W_RANKING_COMPONENT / 2,
                                                            Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + MARGIN_UPPER_TO_RANKING,
                                                            W_RANKING_COMPONENT,
                                                            H_RANKING_COMPONENT)];
//    CGRect rect = CGRectMake(x_frame_center - W_RANKING_COMPONENT / 2,
//                             Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + 10,
//                             W_RANKING_COMPONENT,
//                             H_RANKING_COMPONENT);
//    NSLog(@"x = %f, y = %f, w = %f, h = %f",
//          rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
    iv_ranking.alpha = ALPHA_COMPONENT;
    [[iv_ranking layer] setCornerRadius:10.0];
    [iv_ranking setClipsToBounds:YES];
    [self.view bringSubviewToFront:iv_ranking];
    [self.view addSubview:iv_ranking];

    
    
//    NSLog(@"count = %d", [[imageFileArray objectAtIndex:0] count]);
    
    //各種アイコン表示部分
    for(int row = 0; row < [imageFileArray count];row++){
//        NSLog(@"row = %d", row);

        for(int col = 0; col < [[imageFileArray objectAtIndex:row] count] ;col++){
//            NSLog(@"row = %d, col = %d", row, col);
            CGRect rect_bt = CGRectMake(
                                        x_frame_center - (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * 2 +
                                        (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * col,
                                        
                                        Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + MARGIN_UPPER_TO_RANKING +
                                        H_RANKING_COMPONENT + MARGIN_RANKING_TO_FORMAL_BUTTON +
                                        (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * row,
                                        
                                        SIZE_FORMAL_BUTTON,
                                        SIZE_FORMAL_BUTTON);
            
            UIButton *bt = [self createButtonWithImage:[[imageFileArray objectAtIndex:row] objectAtIndex:col]
                                                   tag:[[[tagArray objectAtIndex:row] objectAtIndex:col ] intValue]//COMPONENT_00でも可
                                                 frame:rect_bt];
            
            [bt addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:bt];
            
//            NSLog(@"row = %d, col = %d, x = %d, y = %d, image = %@",
//                  row, col,
//                  (int)rect_bt.origin.x, (int)rect_bt.origin.y,
//                  [[imageFileArray objectAtIndex:row] objectAtIndex:col]);
        }
    }
    
    //スタートボタン表示部分
    CGRect rect_start = CGRectMake(x_frame_center - W_BT_START/2,
                                   Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + MARGIN_UPPER_TO_RANKING +
                                   H_RANKING_COMPONENT + MARGIN_RANKING_TO_FORMAL_BUTTON +
                                   (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * [imageFileArray count] + MARGIN_FORMAL_TO_START,
                                   W_BT_START,
                                   H_BT_START);
    UIButton *bt_start = [self createButtonWithImage:@"white_128.png"
                                           tag:0
                                         frame:rect_start];
    
    [bt_start addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
    
    //丸角
    [[bt_start layer] setCornerRadius:10.0];
    [bt_start setClipsToBounds:YES];
    [self.view addSubview:bt_start];
    
    
    //キャラ変更部分(購入部分)
    
    
    //機体数増加部分(購入ページ)
    
    NSLog(@"ItemViewController start");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushed_button: (id)sender
{
    NSLog(@"%d", [sender tag]);
    if ([sender tag] == 0) {
        NSLog(@"%d", 0);
    }
    switch([sender tag]){
        case 0:{
            NSLog(@"start games");
            GameClassViewController *gameView = [[GameClassViewController alloc] init];
            [self presentViewController: gameView animated:YES completion: nil];
            //参考戻る時(時間経過等ゲーム終了時で)：[self dismissModalViewControllerAnimated:YES];
//            NSLog(@"return");
//            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 200:{
            //武器バージョンアップ
            
            subView = [self createView];
            [self.view addSubview:subView];
            
            
            CGRect rect_close = CGRectMake(270, 60, 35, 35);
            closeButton = [self createButtonWithImage:@"red.png" tag:999 frame:rect_close];
            [self.view addSubview:closeButton];
            break;
        }
        case 201:{
            break;
        }
        case 202:{
            break;
        }
        case 203:{
            break;
        }
        case 210:{
            break;
        }
        case 211:{
            break;
        }
        case 212:{
            break;
        }
        case 213:{
            break;
        }
        case 220:{
            break;
        }
        case 221:{
            break;
        }
        case 222:{
            break;
        }
        case 223:{
            break;
        }
        case 999:
            [subView removeFromSuperview];
            [closeButton removeFromSuperview];
            
    }
}

-(UIButton*)createButtonWithImage:(NSString*)imageFile tag:(int)tag frame:(CGRect)frame
{
    //画像を表示させる場合：http://blog.syuhari.jp/archives/1407
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    button.tag   = tag;
    UIImage *image = [UIImage imageNamed:imageFile];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushed_button:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}
-(UIButton*)createButtonWithTitle:(NSString*)title tag:(int)tag frame:(CGRect)frame
{
    //画像を表示させる場合：http://blog.syuhari.jp/archives/1407
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    button.tag   = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushed_button:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}


-(UIImageView*)createImageView:(NSString*)filename tag:(int)tag frame:(CGRect)frame{
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
    iv.tag = tag;
    iv.image = [UIImage imageNamed:filename];
    return iv;
}

-(UIView *)createView{
    
    UIView *view = [[UIView alloc]init];
    
    //            view.frame = self.view.bounds;//画面全体
    view.frame = CGRectMake(10, 50, 300, 400);
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5f;
    //            [self.view addSubview:view];
    
    //丸角にする
    [[view layer] setCornerRadius:10.0];
    [view setClipsToBounds:YES];
    
    //UIViewに枠線を追加する
    [[view layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[view layer] setBorderWidth:1.0];
    
    [self.view bringSubviewToFront:view];
//    [self.view addSubview:view];
    return view;
    

}

@end
