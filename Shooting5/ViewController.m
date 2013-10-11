//
//  ViewController.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/25.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "ViewController.h"
#import "ItemSelectViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    CGRect rect_frame = [[UIScreen mainScreen] bounds];
    CGRect rect_main = CGRectMake(0,30, 320, 320);
    UIImageView *iv_frame = [[UIImageView alloc]initWithFrame:rect_main];
    iv_frame.image = [UIImage imageNamed:@"chara_test2.png"];
    
    [self.view addSubview:iv_frame];
    
    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/ユーザー認証_/_/_/_/_/_/_/_/_/_/
    //IDを取得する
    NSUserDefaults* id_defaults =
        [NSUserDefaults standardUserDefaults];
//    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
    int user_id = [id_defaults integerForKey:@"user_id"];
    NSLog(@"userid = %d", user_id);
    //IDがない場合、十分に長い乱数を取得してIDとして記憶
    if(user_id == 0){
        //取得
//        int temp1 = arc4random() % 100;
//        int temp2 = arc4random() % 100;
//        int temp3 = arc4random() % 100;
//        user_id = abs(temp1 * temp2 * temp3);
        user_id = abs(arc4random()%INT_MAX);
//        NSLog(@"新規取得userid = %d, %d, %d, %d , %d", user_id, temp1, temp2, temp3, (temp1 * temp2 * temp3));
        NSLog(@"新規取得userid = %d", user_id);
        //記録
        [id_defaults setInteger:user_id forKey:@"user_id"];
    }else{
        NSLog(@"ログイン完了：user_id = %d", user_id);
    }
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    //viewDidLoadの次に呼び出される
    CGRect rect_frame = [[UIScreen mainScreen] bounds];
    UIButton *bt = [self createButtonWithTitle:@"setting"
                                           tag:0
                                         frame:CGRectMake(rect_frame.size.width/2 - 50,
                                                          rect_frame.size.height/2 + 130,
                                                          100,
                                                          40)];
    
    
    [bt addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushed_button:(id)sender{
    UIStoryboard *storyboard = nil;

    switch([sender tag]){
        case 0:
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ItemSelectViewController"];
            //    NSLog(@"%@", vc);
            [self presentViewController: vc animated:YES completion: nil];
            break;
//        case 1:
//            NSLog(@"bb@");
//            break;

    }
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

@end
