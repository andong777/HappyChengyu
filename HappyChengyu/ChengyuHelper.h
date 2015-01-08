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
@property (nonatomic, strong, readonly) NSArray *appearedList;

+ (instancetype)sharedInstance;
- (void)reloadData;

- (Chengyu *)randomWithRemove:(BOOL)remove;
- (Chengyu *)findNextWithFirstCharacter:(NSString *)character andRemove:(BOOL)remove;
- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include andRemove:(BOOL)remove;
- (NSArray *)findAllWithFirstCharacter:(NSString *)character;
- (NSArray *)findAllWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include;
- (Chengyu *)getByName:(NSString *)name;
- (Chengyu *)checkValidByName:(NSString *)name andCharacter:(NSString *)character error:(NSError **)error;
- (Chengyu *)checkValidByName:(NSString *)name andPinyin:(NSString *)pinyin includingTone:(BOOL)include error:(NSError **)error;

- (BOOL)modifyDataAndSave;

@end
