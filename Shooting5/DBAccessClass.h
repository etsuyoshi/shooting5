//
//  DBAccessClass.h
//  Shooting5
//
//  Created by 遠藤 豪 on 13/10/13.
//  Copyright (c) 2013年 endo.tuyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBAccessClass : NSObject{
    
}

-(NSString *)getIdFromDevice;
-(Boolean)setIdToDB:(NSString *)arg_id;
-(Boolean)updateInitView:(NSString *)arg_id;
-(Boolean)updateValueToDB:(NSString *)user_id column:(NSString *)column newVal:(NSString *)newValue;
-(NSString *)getValueFromDB:(NSString *)user_id column:(NSString *)column;
-(Boolean)getIsRegisteredID:(NSString *)_strId;
-(Boolean)initUserRegister:(NSString *)_strId;
-(NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict;
@end
