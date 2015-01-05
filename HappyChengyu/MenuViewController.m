//
//  ViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "MenuViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface MenuViewController () {
    Chengyu *currentChengyu;
    BOOL _began;
}

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *theSwitch;

- (IBAction)clickStart:(UIButton *)sender;
- (IBAction)clickAnswer:(UIButton *)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _began = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickStart:(UIButton *)sender {
    currentChengyu = [[ChengyuHelper sharedInstance] random];
    [self setContent];
    _began = YES;
}

- (IBAction)clickAnswer:(UIButton *)sender {
    if(!_began){
        return;
    }
    Chengyu *answer = nil;
    if(_theSwitch.isOn){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstCharacter:theCharacter];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        NSLog(@"pinyin: %@", thePinyin);
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstPinyin:thePinyin];
    }
    if(answer){
        NSLog(@"%@", answer.name);
        currentChengyu = answer;
        [self setContent];
    }else{
        _questionLabel.text = @"找不到候选词";
        _began = NO;
    }
}

- (void)setContent {
    if(currentChengyu){
        _questionLabel.text = currentChengyu.name;
        _detailLabel.text = currentChengyu.meaning;
    }
}

@end
