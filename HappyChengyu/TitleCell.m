//
//  CustomCell.m
//  HappyChengyu
//
//  Created by andong on 15/1/12.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "TitleCell.h"

@implementation TitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
