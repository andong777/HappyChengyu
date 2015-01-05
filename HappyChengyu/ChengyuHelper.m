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


#define kFileName @"chengyu"
#define kFileType @"json"


@interface ChengyuHelper() {
    NSMutableArray *_chengyuList;
    NSMutableArray *_appearedList;
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
        NSString *path = [[NSBundle mainBundle] pathForResource:kFileName ofType:kFileType];
        NSData *JSONData = [NSData dataWithContentsOfFile:path];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
        NSArray *array = [dictionary valueForKey:@"Chengyu"];
        _chengyuList = [[MTLJSONAdapter modelsOfClass:[Chengyu class] fromJSONArray:array error:nil] mutableCopy];
        _appearedList = nil;
    }
    return self;
}

- (void)loadData {
    [_chengyuList addObjectsFromArray:_appearedList];
    _appearedList = nil;
}

- (Chengyu *)random {
    NSUInteger index = arc4random() % [_chengyuList count];
    Chengyu *result = [_chengyuList objectAtIndex:index];
    [_chengyuList removeObject:result];
    [_appearedList addObject:result];
    return result;
}

- (NSArray *)find:(NSInteger)number withFirstCharacter:(NSString *)character {
    NSPredicate *select = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@ AND %K.length == 4", @"name", character, @"name"];
    NSArray *results = [_chengyuList filteredArrayUsingPredicate:select];
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
    [_chengyuList removeObject:result];
    [_appearedList addObject:result];
    return result;
}

- (NSArray *)find:(NSInteger)number withFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include {
    NSPredicate *select = nil;
    if(include){
        select = [NSPredicate predicateWithFormat:@"%K[FIRST] == %@ AND %K.length == 4", @"pinyin", pinyin, @"name"];
    }else{
        select = [NSPredicate predicateWithFormat:@"%K[FIRST] ==[cd] %@ AND %K.length == 4", @"pinyin", pinyin, @"name"];
    }
    NSArray *results = [_chengyuList filteredArrayUsingPredicate:select];
    if(!results || [results count] == 0){
        return nil;
    }
    NSRange theRange;
    theRange.location = 0;
    theRange.length = number < [results count]? number : [results count];
    return [results subarrayWithRange:theRange];
}

- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin
                       includingTone:(BOOL)include {
    NSArray *array = [self find:1 withFirstPinyin:pinyin includingTone:include];
    Chengyu *result = nil;
    if(array && [array count] > 0){
        result = [array objectAtIndex:0];
    }
    return result;
}

- (BOOL)checkIsValid:(NSString *)chengyuName withError:(NSError *)error {
    if([chengyuName length] != 4){
        error = [NSError errorWithDomain:@"customised" code:WrongLengthError userInfo:nil];
        return NO;
    }
    for(Chengyu *cy in _appearedList){
        if([cy.name isEqualToString:chengyuName]){
            error = [NSError errorWithDomain:@"customised" code:UsedNameError userInfo:nil];
            return NO;
        }
    }
    for(NSUInteger i = 0; i < [_chengyuList count]; i++){
        if([[_chengyuList[i] name] isEqualToString:chengyuName]){
            [_chengyuList removeObjectAtIndex:i];
            [_appearedList addObject:_chengyuList[i]];
            return YES;
        }
    }
    error = [NSError errorWithDomain:@"customised" code:UnknownError userInfo:nil];
    return NO;
}

@end
