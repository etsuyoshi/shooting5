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

#define SIZE_FORMAL_BUTTON 50

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
                      [NSArray arrayWithObjects:@"red.png", @"red.png", @"blue_item_yuri_big.png", nil],
                      [NSArray arrayWithObjects:@"blue_item_yuri_big.png", @"red.png", @"yellow_item_thunder.png", nil], nil];
    NSLog(@"bbb");
    
    tagArray = [NSArray arrayWithObjects:
                [NSArray arrayWithObjects:@"00", @"01", @"02", nil],
                [NSArray arrayWithObjects:@"10", @"11", @"12", nil], nil];
    NSLog(@"ccc");

	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{

    NSLog(@"000");
    for(int row = 0; row < 2;row++){
        NSLog(@"row = %d", row);

        for(int col = 0; col < 3 ;col++){
//            NSLog(@"col = %d", col);
            //ボタン
            UIButton *bt = [self createButtonWithImage:
                            [[imageFileArray objectAtIndex:row] objectAtIndex:col]
//                                                   tag:COMPONENT_00
                                                   tag:[[[tagArray objectAtIndex:row] objectAtIndex:col ] intValue]//COMPONENT_00でも可
//                                                   tag:[tab_array objectAtIndex:row]
                                                 frame:CGRectMake(col * (SIZE_FORMAL_BUTTON + 10),
                                                                  row * (SIZE_FORMAL_BUTTON + 10) + 40,
                                                                  SIZE_FORMAL_BUTTON,
                                                                  SIZE_FORMAL_BUTTON)];
            
            [bt addTarget:self action:@selector(pushed_button:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:bt];
            
            NSLog(@"row = %d", row);
        }
    }
    
    
    
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
