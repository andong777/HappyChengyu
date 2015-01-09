//
//  FavoritesHelper.h
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Chengyu;

@interface FavoritesHelper : NSObject

@property (nonatomic, strong) NSDictionary *favorites;

+ (FavoritesHelper *)sharedInstance;

- (BOOL)addFavorite:(Chengyu *)chengyu;
- (BOOL)removeFavorite:(Chengyu *)chengyu;
- (BOOL)hasFavorite:(Chengyu *)chengyu;
- (BOOL)saveFavorites;

@end
