//
//  Chengyu.h
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Chengyu : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *pinyin;
@property (nonatomic, strong) NSString *meaning;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *example;
@property (nonatomic, strong) NSString *abbr;

@end
