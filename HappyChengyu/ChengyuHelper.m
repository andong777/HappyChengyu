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

//#define TEST
#ifdef TEST
    #define kFileName @"test"
#else
    #define kFileName @"chengyu"
#endif
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
        _appearedList = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)reloadData {
    [_appearedList removeAllObjects];
}

- (Chengyu *)random {
    NSUInteger index = arc4random() % [_chengyuList count];
    Chengyu *result = [_chengyuList objectAtIndex:index];
    [_chengyuList removeObject:result];
    [_appearedList addObject:result];
    return result;
}

- (NSArray *)findAllWithFirstCharacter:(NSString *)character {
    NSPredicate *select = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", @"name", character];
    return [_chengyuList filteredArrayUsingPredicate:select];
}

- (Chengyu *)findNextWithFirstCharacter:(NSString *)character {
    NSMutableArray *candidates = [[self findAllWithFirstCharacter:character] mutableCopy];
    if(candidates && [candidates count]){
        NSUInteger index = arc4random() % [candidates count];
        Chengyu *result = [candidates objectAtIndex:index];
        [candidates removeObjectAtIndex:index];
        [_appearedList addObject:result];
        return result;
    }
    return nil;
}

- (NSArray *)findAllWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include {
    NSPredicate *select = nil;
    if(include){
        select = [NSPredicate predicateWithFormat:@"%K[FIRST] == %@", @"pinyin", pinyin];
    }else{
        select = [NSPredicate predicateWithFormat:@"%K[FIRST] ==[cd] %@", @"pinyin", pinyin];
    }
    return [_chengyuList filteredArrayUsingPredicate:select];
}

- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin
                       includingTone:(BOOL)include {
    NSMutableArray *candidates = [[self findAllWithFirstPinyin:pinyin includingTone:include] mutableCopy];
    if(candidates && [candidates count]){
        NSUInteger index = arc4random() % [candidates count];
        Chengyu *result = [candidates objectAtIndex:index];
        [candidates removeObjectAtIndex:index];
        [_appearedList addObject:result];
        return result;
    }
    return nil;
}

- (Chengyu *)getByName:(NSString *)name {
    for(Chengyu *cy in _chengyuList){
        if([cy.name isEqualToString:name]){
            return cy;
        }
    }
    return nil;
}

- (Chengyu *)checkValidByName:(NSString *)name andCharacter:(NSString *)character error:(NSError **)error {
    if(!name){
        *error = [NSError errorWithDomain:@"customised" code:InvalidInputError userInfo:nil];
        return nil;
    }
    if([name length] != 4){
        *error = [NSError errorWithDomain:@"customised" code:WrongLengthError userInfo:nil];
        return nil;
    }
    if(![name hasPrefix:character]){
        *error = [NSError errorWithDomain:@"customised" code:IncorrectStartError userInfo:nil];
        return nil;
    }
    for(Chengyu *cy in _appearedList){
        if([cy.name isEqualToString:name]){
            *error = [NSError errorWithDomain:@"customised" code:UsedNameError userInfo:nil];
            return nil;
        }
    }
    for(NSUInteger i = 0; i < [_chengyuList count]; i++){
        Chengyu *one = _chengyuList[i];
        if([one.name isEqualToString:name]){
            [_chengyuList removeObjectAtIndex:i];
            [_appearedList addObject:one];
            return one;
        }
    }
    *error = [NSError errorWithDomain:@"customised" code:NonExistentNameError userInfo:nil];
    return nil;
}

- (Chengyu *)checkValidByName:(NSString *)name andPinyin:(NSString *)pinyin includingTone:(BOOL)include error:(NSError *__autoreleasing *)error {
    if(!name){
        *error = [NSError errorWithDomain:@"customised" code:InvalidInputError userInfo:nil];
        return nil;
    }
    if([name length] != 4){
        *error = [NSError errorWithDomain:@"customised" code:WrongLengthError userInfo:nil];
        return nil;
    }
    for(Chengyu *cy in _appearedList){
        if([cy.name isEqualToString:name]){
            *error = [NSError errorWithDomain:@"customised" code:UsedNameError userInfo:nil];
            return nil;
        }
    }
    for(NSUInteger i = 0; i < [_chengyuList count]; i++){
        Chengyu *one = _chengyuList[i];
        if([one.name isEqualToString:name]){
            NSString *startingPinyin = [one.pinyin objectAtIndex:0];
            BOOL isEqual = NO;
            if(include){
                isEqual = [pinyin isEqualToString:startingPinyin];
            }else{
                isEqual = ([pinyin compare:startingPinyin options:NSDiacriticInsensitiveSearch] == NSOrderedSame);
            }
            if(isEqual){
                [_chengyuList removeObjectAtIndex:i];
                [_appearedList addObject:one];
                return one;
            }else{
                *error = [NSError errorWithDomain:@"customised" code:IncorrectStartError userInfo:nil];
                return nil;
            }
        }
    }
    *error = [NSError errorWithDomain:@"customised" code:NonExistentNameError userInfo:nil];
    return nil;
}

- (BOOL)modifyDataAndSave {
    NSLog(@"modification begins");
    NSMutableArray *fourcyList = [NSMutableArray arrayWithCapacity:13000];
    for(Chengyu *cy in _chengyuList){
        cy.abbr = [cy.abbr uppercaseString];
        [fourcyList addObject:cy];
    }
    NSArray *array = [MTLJSONAdapter JSONArrayFromModels:fourcyList];
    NSDictionary *dictionary = @{@"Chengyu": array};
    NSError *error = nil;
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if(!JSONdata){
        NSLog(@"error: %@", error);
        return NO;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:kFileName ofType:kFileType];
    NSLog(@"output path: %@", path);
    return [JSONdata writeToFile:path atomically:YES];
}

@end
