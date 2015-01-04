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
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chengyu" ofType:@"json"];
        NSLog(@"path: %@", path);
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

@end
