//
//  DBAccessClass.m
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/13.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import "DBAccessClass.h"

@implementation DBAccessClass


/**
 *idは端末側に保存されているものとする(なければ新規作成)
 */


-(NSString *)getIdFromDevice{
    NSUserDefaults* id_defaults =
    [NSUserDefaults standardUserDefaults];
    //    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
    //    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
    //    [id_defaults removeObjectForKey:@"user_id"];//値を削除：テスト用
    NSString *_registeredId = [id_defaults stringForKey:@"user_id"];
    NSLog(@"userid = %@", _registeredId);
    
    //端末に記録されたIDがない場合、十分に?長い(5桁)乱数を取得してIDとして記憶
    if(_registeredId == NULL){
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
        //端末記録
        NSUserDefaults *_ud = [NSUserDefaults standardUserDefaults];
        [_ud setObject:newId forKey:@"user_id"];
        
        _registeredId = newId;//
    }else{
        NSLog(@"既存idでログイン完了：user_id = %@", _registeredId);
    }
    return _registeredId;
}

/**
 *サーバー情報(※)と照合(なければdbに新規登録)
 *true:サーバーになければ新規作成、あればそのまま
 *false:サーバーになくて新規作成が未完了の場合
 */
-(Boolean)setIdToDB:(NSString *)arg_id{
    //IDを取得する
    NSString *_registeredId = [self getIdFromDevice];
    
    //サーバーにアクセスしてユーザー情報を登録
    //http://satoshi.upper.jp/user/shooting/usermanage.php
    
    if(![self getIsRegisteredID:_registeredId]){
        
        NSLog(@"未登録idなので新規登録します");
        
        //sqlサーバーに新規登録する
        if([self initUserRegister:_registeredId]){
            NSLog(@"sqlサーバーに登録完了");
        }else{
            NSLog(@"サーバーに登録できませんでした。");
            return false;
        }
    }else{
        
        NSLog(@"登録されたidが存在するのでこのまま続けます。");//=>return true;
    }
    return true;
    
    
//    NSLog(@"%d", [self updateInitView]);

    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    
    
    //    return;
}


-(Boolean)updateValueToDB:(NSString *)user_id column:(NSString *)column newVal:(NSString *)newValue{
    //実行sql：$sql = "update dbusermanage SET $_POST[column] = '$_POST[value]' WHERE id = '$_POST[id]'";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"column"];
    [dict setObject:newValue forKey:@"value"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/updatevalue.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"同期通信失敗");
        return false;
    }else{
        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"getValueFromDB = %@", resultString);
    
    
    
    return true;
}

//【一般型】指定したidの、指定したカラムを取得する
-(NSString *)getValueFromDB:(NSString *)user_id column:(NSString *)column{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"item"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/getvalue.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"同期通信失敗");
        return nil;
    }else{
        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"getValueFromDB = %@", resultString);
    
    return resultString;
}


//データベースにidがあればtrue,なければfalse
-(Boolean)getIsRegisteredID:(NSString *)_strId{
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
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"php output : %@", resultString);
    switch([resultString intValue]){
        case 0:
        {
            NSLog(@"データベースを検索した結果、新規データです");
            return false;
            //            break;
        }
        default:
        {
            NSLog(@"データベースを検索した結果、%d件の重複データ存在します。", [resultString intValue]);
            return true;
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
    
    //ここに制御文が移ることはない
    return false;
}
-(Boolean)initUserRegister:(NSString *)_strId{
    
    
    NSURL* url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/usermanage.php"];
    
    
    //熟達本sect3
    //送信するデータの作成
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:@"no_name" forKey:@"name"];//登録時に再度ユーザーに確認を取る
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"score"];
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"gold"];
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"login"];//ログイン回数
    [dict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"gamecnt"];//ゲーム回数
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
    NSLog(@"str = %@", str);
    NSLog(@"return data = %@", data);
    return data;
}


@end
