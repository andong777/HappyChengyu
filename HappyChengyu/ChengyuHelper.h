//
//  Chengyu.h
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Chengyu;

@interface ChengyuHelper : NSObject

+ (instancetype)sharedInstance;
- (Chengyu *)random;
- (Chengyu *)findNextWithFirstCharacter: (NSString *)character;
- (Chengyu *)findNextWithFirstPinyin: (NSString *)pinyin;
- (Chengyu *)find: (NSInteger)number withFirstCharacter: (NSString *)character;
- (Chengyu *)find: (NSInteger)number withFirstPinyin: (NSString *)pinyin;

@end
