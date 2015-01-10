//
//  FavoritesHelper.m
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "FavoritesHelper.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

#define kFavoritesFileName @"favorites.json"

@interface FavoritesHelper() {
    NSMutableDictionary *_favorites;
    BOOL contentsChanged;
}

@end

@implementation FavoritesHelper

+ (FavoritesHelper *)sharedInstance {
    static FavoritesHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if(self){
        contentsChanged = NO;
        _favorites = [NSMutableDictionary dictionary];
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documentDirectory stringByAppendingPathComponent:kFavoritesFileName];
//        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            NSData *JSONData = [NSData dataWithContentsOfFile:path];
            if(JSONData){
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
                for(NSString *key in [dictionary allKeys]){
                    NSArray *array = [dictionary valueForKey:key];
                    NSMutableArray *transformedArray = [[MTLJSONAdapter modelsOfClass:[Chengyu class] fromJSONArray:array error:nil] mutableCopy];
                    [_favorites setValue:transformedArray forKey:key];
                }
            }
//        }
    }
    return self;
}

- (BOOL)addFavorite:(Chengyu *)chengyu {
    if([self hasFavorite:chengyu]){
        return NO;
    }
    NSString *category = [chengyu.abbr substringToIndex:1];
    NSMutableArray *array = [_favorites valueForKey:category];
    if(!array){
        array = [NSMutableArray array];
    }
    NSLog(@"category %@ has %lu items", category, [array count]);
    [array addObject:chengyu];
    [_favorites setValue:array forKey:category];
    contentsChanged = YES;
    NSLog(@"chengyu %@ added", chengyu.name);
    return YES;
}

- (BOOL)removeFavorite:(Chengyu *)chengyu {
    if(![self hasFavorite:chengyu]){
        return NO;
    }
    NSString *category = [chengyu.abbr substringToIndex:1];
    NSMutableArray *array = [_favorites valueForKey:category];
    [array removeObject:chengyu];
    if(array && [array count] > 0){
        [_favorites setValue:array forKey:category];
    }else{
        [_favorites setValue:nil forKey:category];
    }
    contentsChanged = YES;
    NSLog(@"chengyu %@ removed", chengyu.name);
    return YES;
}

- (BOOL)hasFavorite:(Chengyu *)chengyu {
    for(NSArray *array in [_favorites allValues]){
        for(Chengyu *cy in array){
            if([cy.name isEqualToString:chengyu.name]){
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)saveFavorites {
    if(!contentsChanged){
        return NO;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(NSString *key in [_favorites allKeys]){
        NSArray *array = [_favorites valueForKey:key];
        if(array && [array count] > 0){
            NSArray *transformedArray = [MTLJSONAdapter JSONArrayFromModels:array];
            [dictionary setValue:transformedArray forKey:key];
        }
    }
    NSError *error = nil;
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if(!JSONdata){
        NSLog(@"error: %@", error);
        return NO;
    }
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:kFavoritesFileName];
    NSLog(@"saving favorites...");
    return [JSONdata writeToFile:path atomically:YES];
}

@end
