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
    NonExistentNameError = 3,
    InvalidInputError = 4,
    IncorrectStartError = 5
};

@interface ChengyuHelper : NSObject

@property (nonatomic, strong, readonly) NSArray *chengyuList;

+ (instancetype)sharedInstance;
- (void)reloadData;

- (Chengyu *)random;
- (Chengyu *)findNextWithFirstCharacter:(NSString *)character;
- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include;
- (NSArray *)findWithFirstCharacter:(NSString *)character;
- (NSArray *)findWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include;

- (Chengyu *)checkValidByName:(NSString *)name andCharacter:(NSString *)character error:(NSError **)error;
- (Chengyu *)checkValidByName:(NSString *)name andPinyin:(NSString *)pinyin includingTone:(BOOL)include error:(NSError **)error;

@end
