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

#define kFavorites @"Favorites"

@implementation FavoritesHelper

+ (FavoritesHelper *)sharedInstance {
    static FavoritesHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

- (BOOL)addFavorite:(Chengyu *)chengyu {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[defaults dictionaryForKey:kFavorites] mutableCopy];
    NSString *firstLetter = [[chengyu.abbr substringToIndex:1] uppercaseString];
    NSMutableArray *theArray = [NSMutableArray arrayWithArray:[dictionary objectForKey:firstLetter]];
    [theArray addObject:chengyu];
    [dictionary setObject:theArray forKey:firstLetter];
    [defaults setObject:dictionary forKey:kFavorites];
    [defaults synchronize];
    return YES;
}

- (BOOL)removeFavorite:(Chengyu *)chengyu {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[defaults dictionaryForKey:kFavorites] mutableCopy];
    NSString *firstLetter = [[chengyu.abbr substringToIndex:1] uppercaseString];
    NSMutableArray *theArray = [NSMutableArray arrayWithArray:[dictionary objectForKey:firstLetter]];
    [theArray removeObject:chengyu];
    [dictionary setObject:theArray forKey:firstLetter];
    [defaults setObject:dictionary forKey:kFavorites];
    [defaults synchronize];
    return YES;
}

- (NSDictionary *)loadFavorites {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionaryWithNames = [defaults dictionaryForKey:kFavorites];
    NSMutableDictionary *dictionaryWithChengyus = [NSMutableDictionary dictionaryWithCapacity:[dictionaryWithNames count]];
    for(id key in [dictionaryWithNames allKeys]){
        NSArray *arrayWithNames = [dictionaryWithNames objectForKey:key];
        NSMutableArray *arrayWithChengyus = [NSMutableArray arrayWithCapacity:[arrayWithNames count]];
        for(NSString *name in arrayWithNames){
            Chengyu *chengyu = [[ChengyuHelper sharedInstance] getByName:name];
            [arrayWithChengyus addObject:chengyu];
        }
        [dictionaryWithChengyus setObject:arrayWithChengyus forKey:key];
    }
    return dictionaryWithChengyus;
}

@end
