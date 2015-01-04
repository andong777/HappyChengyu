//
//  Chengyu.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "Chengyu.h"

@implementation Chengyu

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"Name",
             @"pinyin": @"Pinyin",
             @"meaning": @"Meaning",
             @"source": @"Source",
             @"example": @"Example",
             @"abbr": @"Abbr"
             };
}

- (NSValueTransformer *)pinyinJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:
            ^(NSString *string){
        return [string componentsSeparatedByString:@" "];
    } reverseBlock:^(NSArray *array){
        return [array componentsJoinedByString:@" "];
    }];
}

@end
