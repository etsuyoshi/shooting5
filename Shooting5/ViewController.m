//
//  ViewController.m
//  ShootingTest
//
//  Created by 遠藤 豪 on 13/09/25.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

//DB側でログイン回数をカウントする(カラム追加、値取得して１を足す)

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
//    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
//    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
    NSString *registeredId = [id_defaults stringForKey:@"user_id"];
    NSLog(@"userid = %@", registeredId);

//    return;
    //端末に記録されたIDがない場合、十分に長い乱数を取得してIDとして記憶
    if(registeredId == NULL){
        //取得
//        NSLog(@"int max = %010d", INT_MAX);//2147483647        
        int random_num = abs(arc4random()%100000);//0-99999=最大5桁の乱数
//        random_num = 1;
//        NSLog(@"rand = %d", random_num);
        NSDateFormatter *_dateformat = [[NSDateFormatter alloc] init];
        [_dateformat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        [_dateformat setDateFormat:@"yyyyMMddHHmmss"];//14桁
        NSString *_now = [_dateformat stringFromDate:[NSDate date]];
//        NSLog(@"%@", _now);
        NSString *newId = [NSString stringWithFormat:@"%@%05d", _now, random_num];//yyyymmddhhmmss+5桁乱数=19桁=mysqlのbigIntの最大格納桁数
//        NSString *newId = [NSString stringWithFormat:@"2013010101010100002"];//上記代替のテスト用id
        NSLog(@"新規取得userid = %@", newId);
        //記録
        [id_defaults setObject:newId forKey:@"user_id"];
    }else{
        NSLog(@"既存idでログイン完了：user_id = %@", registeredId);
    }
    
    //本来なら、アクセスしたサーバーのレコードからid情報を検索し、なければ新規登録、あればそのまま続行
    //サーバーにアクセスしてユーザー情報を登録
    //http://satoshi.upper.jp/user/shooting/usermanage.php
    
    if([self getIsUniqueID:[id_defaults stringForKey:@"user_id"]]){
        
        NSLog(@"ユニークidです");
        
        //新規登録する
        if([self initUserRegister:[id_defaults stringForKey:@"user_id"]]){
            NSLog(@"サーバーに登録完了");
        }else{
            NSLog(@"サーバーに登録できませんでした。");
        }
    }else{
        
        NSLog(@"重複したidがあります");
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

-(Boolean)getIsUniqueID:(NSString *)_strId{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:_strId forKey:@"find_id"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
    
    
    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/userfind.php"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [ NSURLConnection sendSynchronousRequest:req
                                          returningResponse:&response
                                                      error:&error];
    
    
    if(error){
        NSLog(@"同期通信失敗!");
        return false;
    }else{
        NSLog(@"同期通信成功!");
    }
    NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"php output : %@", resultString);
    switch([resultString intValue]){
        case 0:
        {
            NSLog(@"データベースを検索した結果、新規データです");
            return true;
//            break;
        }
        default:
        {
            NSLog(@"データベースを検索した結果、%d件の重複データ存在します。", [resultString intValue]);
            return false;
//            break;
        }
    }
    
    /*
    if([resultString isEqualToString:@"0"]){
        NSLog(@"重複データが存在します");
        return false;
    }else if([resultString isEqualToString:@"this is new id"]){
        NSLog(@"新規データです");
        return true;
    }
    */
    
    
    return false;
}
-(Boolean)initUserRegister:(NSString *)_strId{
    
    
    NSURL* url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/usermanage.php"];
    
    
    //熟達本sect3
    //送信するデータの作成
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:@"test_name" forKey:@"name"];
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"score"];
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"gold"];
    [dict setObject:_strId forKey:@"id"];
    
    
    NSData *data = [self formEncodedDataFromDictionary:dict];//引数のデータ(mysqlに格納するデータ列)を作成
    
    // 接続要求を作成する
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    // HTTPのメソッドをPOSTに設定する
    [req setHTTPMethod:@"POST"];
    // POSTのデータとして設定する
    [req setHTTPBody:data];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"error = %@", error);
        NSLog(@"exit in order error");
        return false;
    }
    NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"registering result = %@", resultString);
    return true;
}


- (NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict
{
    NSMutableString *str;
    
    str = [NSMutableString stringWithCapacity:0];
    
    // 「キー=値」のペアを「&」で結合して列挙する
    // キーと値はどちらもURLエンコードを行い、スペースは「+」に置き換える
    for (NSString __strong *key in [dict allKeys])
    {
        //        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *value = [dict objectForKey:key];
        
        // スペースを「+」に置き換える
        key = [key stringByReplacingOccurrencesOfString:@" "
                                             withString:@"+"];
        value = [value stringByReplacingOccurrencesOfString:@" "
                                                 withString:@"+"];
        
        
        // URLエンコードを行う
        key = [key stringByAddingPercentEscapesUsingEncoding:
               NSUTF8StringEncoding];
        value = [value stringByAddingPercentEscapesUsingEncoding:
                 NSUTF8StringEncoding];
        
        // 文字列を連結する
        if ([str length] > 0)
        {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, value];
        //        [pool drain];
    }
    
    // 作成した文字列をUTF-8で符号化する
    NSData *data;
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"str = %@", str);
//    NSLog(@"return data = %@", data);
    return data;
}

@end
