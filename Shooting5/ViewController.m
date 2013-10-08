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
