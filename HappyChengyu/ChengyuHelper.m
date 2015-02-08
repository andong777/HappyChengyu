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

@implementation ChengyuHelper

+ (ChengyuHelper *)sharedInstance {
    static ChengyuHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"chengyu data loaded now");
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
        _chengyuList = [[MTLJSONAdapter modelsOfClass:[Chengyu class] fromJSONArray:array error:nil] mutableCopy];
        _appearedList = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)reloadData {
    [self.appearedList removeAllObjects];
}

- (Chengyu *)randomWithRemove:(BOOL)remove {
    Chengyu *result = nil;
    NSArray *candidatesAfterResult = nil;
    do {
        NSUInteger index = arc4random() % [_chengyuList count];
        result = [_chengyuList objectAtIndex:index];
        if(![_appearedList containsObject:result]){
            NSString *character = [result.name substringFromIndex:[result.name length] - 1];
            candidatesAfterResult = [self findAllWithFirstCharacter:character];
        }
    } while (!candidatesAfterResult || [candidatesAfterResult count] == 0);
    
    if(remove){
        [self.appearedList addObject:result];
    }
    return result;
}

- (NSArray *)findAllWithFirstCharacter:(NSString *)character {
    NSPredicate *select = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", @"name", character];
    NSMutableArray *candidates =  [[_chengyuList filteredArrayUsingPredicate:select] mutableCopy];
    [candidates removeObjectsInArray:_appearedList];
    return candidates;
}

- (Chengyu *)findNextWithFirstCharacter:(NSString *)character andRemove:(BOOL)remove {
    NSArray *candidates = [self findAllWithFirstCharacter:character];
    if(candidates && [candidates count]){
        NSUInteger index = arc4random() % [candidates count];
        Chengyu *result = [candidates objectAtIndex:index];
        if(remove){
            [self.appearedList addObject:result];
        }
        return result;
    }
    return nil;
}

+ (BOOL)comparePinyinWithoutToneString:(NSString *)string anotherString:(NSString *)anotherString {
    static NSString *v = @"v";
    NSString *testString = string;
    NSString *anotherTestString = anotherString;
    if([string hasSuffix:@"ü"] || [string hasSuffix:@"ǘ"] || [string hasSuffix:@"ǚ"] || [string hasSuffix:@"ǜ"]){
        testString = [string stringByAppendingString:v];
    }
    if([anotherString hasSuffix:@"ü"] || [anotherString hasSuffix:@"ǘ"] || [anotherString hasSuffix:@"ǚ"] || [anotherString hasSuffix:@"ǜ"] || [anotherString hasSuffix:@""]){
        anotherTestString = [anotherString stringByAppendingString:v];
    }
    return [testString compare:anotherTestString options:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (NSArray *)findAllWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include {
    if(include){
        NSPredicate *select = [NSPredicate predicateWithFormat:@"%K[FIRST] == %@", @"pinyin", pinyin];
        NSMutableArray *candidates = [[_chengyuList filteredArrayUsingPredicate:select] mutableCopy];
        [candidates removeObjectsInArray:_appearedList];
        return candidates;
    }else{
        // TODO 对拼音“吁”的判断有误，会将其变成“u”。
//        NSPredicate *select = [NSPredicate predicateWithFormat:@"%K[FIRST] ==[cd] %@", @"pinyin", pinyin];
        NSMutableArray *candidates = [NSMutableArray array];
        for(Chengyu *cy in _chengyuList){
            if([[self class ]comparePinyinWithoutToneString:[cy.pinyin firstObject] anotherString:pinyin]){
                [candidates addObject:cy];
            }
        }
        return candidates;
    }
}

- (Chengyu *)findNextWithFirstPinyin:(NSString *)pinyin includingTone:(BOOL)include andRemove:(BOOL)remove {
    NSArray *candidates = [self findAllWithFirstPinyin:pinyin includingTone:include];
    if(candidates && [candidates count]){
        NSUInteger index = arc4random() % [candidates count];
        Chengyu *result = [candidates objectAtIndex:index];
        if(remove){
            [self.appearedList addObject:result];
        }
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
    if(!name || [name length] == 0){
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
            [self.appearedList addObject:one];
            return one;
        }
    }
    *error = [NSError errorWithDomain:@"customised" code:NonExistentNameError userInfo:nil];
    return nil;
}

- (Chengyu *)checkValidByName:(NSString *)name andPinyin:(NSString *)pinyin includingTone:(BOOL)include error:(NSError *__autoreleasing *)error {
    if(!name || [name length] == 0){
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
            NSString *startingPinyin = [one.pinyin firstObject];
            BOOL isEqual = NO;
            if(include){
                isEqual = [pinyin isEqualToString:startingPinyin];
            }else{
                isEqual = [[self class] comparePinyinWithoutToneString:pinyin anotherString:startingPinyin];
            }
            if(isEqual){
                [self.appearedList addObject:one];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:kFileName ofType:@"json"];
    NSLog(@"output path: %@", path);
    return [JSONdata writeToFile:path atomically:YES];
}

@end
