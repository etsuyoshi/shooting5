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
    
    // 生成例
    ItemSelectViewController *vc = [[ItemSelectViewController alloc] init];
    [self presentmodalViewController:self animated:YES];

    
    // xibファイルからの生成例
//    vc =
//    [[UIViewController alloc] initWithNibName:
//     @"hogeView" bundle:[NSBundle mainBundle]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
