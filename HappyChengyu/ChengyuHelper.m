//
//  Chengyu.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ChengyuHelper.h"
#import "Chengyu.h"
#import <Mantle/Mantle.h>

@interface ChengyuHelper() {
    NSArray *_chengyuList;
}
@end

@implementation ChengyuHelper

+ (ChengyuHelper *)sharedInstance {
    static ChengyuHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if(self){
        NSString *path = [[NSBundle mainBundle] pathForResource:kFileName ofType:@"json"];
        NSData *JSONData = [NSData dataWithContentsOfFile:path];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
        NSArray *array = [dictionary valueForKey:@"Chengyu"];
        _chengyuList = [MTLJSONAdapter modelsOfClass:[Chengyu class] fromJSONArray:array error:nil];
    }
    return self;
}

- (NSArray *)chengyuList {
    return _chengyuList;
}

- (Chengyu *)random {
    NSUInteger index = arc4random() % [[self chengyuList] count];
    return [[self chengyuList] objectAtIndex:index];
}

- (NSArray *)find:(NSInteger)number withFirstCharacter:(NSString *)character {
    NSPredicate *select = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", @"name", character];
    NSArray *results = [[self chengyuList] filteredArrayUsingPredicate:select];
    if(!results || [results count] == 0){
        return nil;
    }
    NSRange theRange;
    theRange.location = 0;
    theRange.length = number < [results count]? number : [results count];
    return [results subarrayWithRange:theRange];
}

- (Chengyu *)findNextWithFirstCharacter:(NSString *)character {
    NSArray *array = [self find:1 withFirstCharacter:character];
    Chengyu *result = nil;
    if(array && [array count] > 0){
        result = [array objectAtIndex:0];
    }
    return result;
}

- (NSArray *)find:(NSInteger)number withFirstPinyin:(NSString *)pinyin {
    NSPredicate *select = [NSPredicate predicateWithFormat:@"%K[FIRST] == %@", @"pinyin", pinyin];
    NSArray *results = [[self chengyuList] filteredArrayUsingPredicate:select];
    if(!results || [results count] == 0){
        return nil;
    }
    NSRange theRange;
    theRange.location = 0;
    theRange.length = number < [results count]? number : [results count];
    return [results subarrayWithRange:theRange];
}

- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin {
    NSArray *array = [self find:1 withFirstPinyin:pinyin];
    Chengyu *result = nil;
    if(array && [array count] > 0){
        result = [array objectAtIndex:0];
    }
    return result;
}

@end
