//
//  Chengyu.h
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Chengyu;

#define kFileName @"chengyu"

@interface ChengyuHelper : NSObject

+ (instancetype)sharedInstance;
- (Chengyu *)random;
- (Chengyu *)findNextWithFirstCharacter: (NSString *)character;
- (Chengyu *)findNextWithFirstPinyin: (NSString *)pinyin;
- (NSArray *)find: (NSInteger)number withFirstCharacter: (NSString *)character;
- (NSArray *)find: (NSInteger)number withFirstPinyin: (NSString *)pinyin;

@end
