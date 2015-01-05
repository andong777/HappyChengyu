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
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UISwitch *characterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;

- (IBAction)clickStart:(UIButton *)sender;
- (IBAction)clickAnswer:(UIButton *)sender;
- (IBAction)toggleCharacterSwitch:(UISwitch *)sender;

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
    _answerButton.enabled = YES;
}

- (IBAction)clickAnswer:(UIButton *)sender {
    if(!_began){
        return;
    }
    Chengyu *answer = nil;
    if(_characterSwitch.isOn){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstCharacter:theCharacter];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        NSLog(@"pinyin: %@", thePinyin);
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstPinyin:thePinyin includingTone:_toneSwitch.isOn];
    }
    if(answer){
        NSLog(@"%@", answer.name);
        currentChengyu = answer;
        [self setContent];
    }else{
        _questionLabel.text = @"找不到候选词";
        _began = NO;
        _answerButton.enabled = NO;
    }
}

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender {
    if(sender.isOn){
        _toneSwitch.enabled = NO;
    }else{
        _toneSwitch.enabled = YES;
    }
}

- (void)setContent {
    if(currentChengyu){
        _questionLabel.text = currentChengyu.name;
        _detailLabel.text = currentChengyu.meaning;
    }
}

@end
