//
//  CustomCell.m
//  HappyChengyu
//
//  Created by andong on 15/1/12.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.opaque = NO;
        self.label.backgroundColor = [UIColor lightGrayColor];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:24.f];
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
