//
//  ItemSelectViewController.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/07.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "ItemSelectViewController.h"

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

#define Y_MOST_UPPER_COMPONENT 30
#define W_MOST_UPPER_COMPONENT 100
#define H_MOST_UPPER_COMPONENT 50


#define SIZE_FORMAL_BUTTON 50
#define INTERVAL_FORMAL_BUTTON 1

#define W_BT_START 150
#define H_BT_START 80

#define ALPHA_COMPONENT 0.5

NSMutableArray *imageFileArray;
NSMutableArray *tagArray;
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
                       @"red.png",
                       @"red.png",
                       @"blue_item_yuri_big2.png",
                       @"yellow_item_thunder.png",
                       nil],
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"red.png",
                       @"yellow_item_thunder.png",
                       @"red.png",
                       nil],
                      
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"red.png",
                       @"yellow_item_thunder.png",
                       @"red.png",
                       nil],
                      
                      [NSArray arrayWithObjects:
                       @"blue_item_yuri_big2.png",
                       @"red.png",
                       @"yellow_item_thunder.png",
                       @"red.png",
                       nil],
                      nil];
//    NSLog(@"imageFileArray initialization complete");
    
    tagArray = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"00", @"01", @"02", @"03", nil],
                [NSArray arrayWithObjects:@"10", @"11", @"12", @"13", nil],
                [NSArray arrayWithObjects:@"20", @"21", @"22", @"23", nil],
                [NSArray arrayWithObjects:@"30", @"31", @"32", @"33", nil],
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
                                                tag:0
                                              frame:CGRectMake(x_frame_center - 10 - W_MOST_UPPER_COMPONENT,
                                                               Y_MOST_UPPER_COMPONENT,
                                                               W_MOST_UPPER_COMPONENT,
                                                               H_MOST_UPPER_COMPONENT)];
    iv_tokuten.alpha = ALPHA_COMPONENT;
    [self.view addSubview:iv_tokuten];
    
    
    
    //獲得コイン数表示部分
    UIImageView *iv_coin = [self createImageView:@"white_128.png"
                                             tag:0
                                           frame:CGRectMake(x_frame_center + 10,
                                                            Y_MOST_UPPER_COMPONENT,
                                                            W_MOST_UPPER_COMPONENT,
                                                            H_MOST_UPPER_COMPONENT)];
    iv_coin.alpha = ALPHA_COMPONENT;
    [self.view addSubview:iv_coin];
    
//    NSLog(@"count = %d", [[imageFileArray objectAtIndex:0] count]);
    
    //各種アイコン表示部分
    for(int row = 0; row < [imageFileArray count];row++){
//        NSLog(@"row = %d", row);

        for(int col = 0; col < [[imageFileArray objectAtIndex:row] count] ;col++){
            NSLog(@"row = %d, col = %d", row, col);
            CGRect rect_bt = CGRectMake(
                                        x_frame_center - (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * 2 +
                                        (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * col,
                                        
                                        Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + 10 +
                                        (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * row,
                                        
                                        SIZE_FORMAL_BUTTON,
                                        SIZE_FORMAL_BUTTON);
            
            UIButton *bt = [self createButtonWithImage:[[imageFileArray objectAtIndex:row] objectAtIndex:col]
                                                   tag:[[[tagArray objectAtIndex:row] objectAtIndex:col ] intValue]//COMPONENT_00でも可
                                                 frame:rect_bt];
            
            [bt addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:bt];
            
            NSLog(@"row = %d, col = %d, x = %d, y = %d, image = %@",
                  row, col,
                  (int)rect_bt.origin.x, (int)rect_bt.origin.y,
                  [[imageFileArray objectAtIndex:row] objectAtIndex:col]);
        }
    }
    
    //スタートボタン表示部分
    CGRect rect_start = CGRectMake(x_frame_center - W_BT_START/2,
                                   Y_MOST_UPPER_COMPONENT + H_MOST_UPPER_COMPONENT + 10 + (SIZE_FORMAL_BUTTON + INTERVAL_FORMAL_BUTTON) * [imageFileArray count] + 50,
                                   W_BT_START,
                                   H_BT_START);
    UIButton *bt = [self createButtonWithImage:@"white_128.png"
                                           tag:0
                                         frame:rect_start];
    
    [bt addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];
    
    
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
        case 0:
            NSLog(@"return");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
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

@end
