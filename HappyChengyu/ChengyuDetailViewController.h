//
//  ChengyuDetailViewController.h
//  HappyChengyu
//
//  Created by andong on 15/1/17.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Chengyu;

@interface ChengyuDetailViewController : UIViewController

@property (nonatomic, strong) Chengyu *chengyu;
@property (nonatomic, assign) BOOL fromFavorite;
@property (nonatomic, copy) UIColor *color;

@end
