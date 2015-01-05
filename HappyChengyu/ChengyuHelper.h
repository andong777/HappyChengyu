//
//  Chengyu.h
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Chengyu;

enum {
    UnknownError = 0,
    WrongLengthError = 1,
    UsedNameError = 2,
    NonExistentNameError = 3
};

@interface ChengyuHelper : NSObject

+ (instancetype)sharedInstance;
- (void)loadData;

- (Chengyu *)random;
- (Chengyu *)findNextWithFirstCharacter:(NSString *)character;
- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include;
- (NSArray *)find:(NSInteger)number withFirstCharacter:(NSString *)character;
- (NSArray *)find:(NSInteger)number withFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include;
- (BOOL)checkIsValid:(NSString *)chengyuName withError:(NSError *)error;

@end
