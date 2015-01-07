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
}

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UISwitch *characterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;
@property (weak, nonatomic) IBOutlet UITextField *answerText;

- (IBAction)clickStart:(UIButton *)sender;
- (IBAction)clickAnswer:(UIButton *)sender;
- (IBAction)toggleCharacterSwitch:(UISwitch *)sender;
- (IBAction)clickCheck:(UIButton *)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickStart:(UIButton *)sender {
//    [[ChengyuHelper sharedInstance] modifyDataAndSave];
    [[ChengyuHelper sharedInstance] reloadData];
    currentChengyu = [[ChengyuHelper sharedInstance] random];
    [self setContent];
    _answerButton.enabled = YES;
}

- (IBAction)clickAnswer:(UIButton *)sender {
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
        _answerButton.enabled = NO;
        [self setContentWithText:@"找不到候选词"];
    }
}

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender {
    if(sender.isOn){
        _toneSwitch.enabled = NO;
    }else{
        _toneSwitch.enabled = YES;
    }
}

- (IBAction)clickCheck:(UIButton *)sender {
    NSString *content = _answerText.text;
    NSError *error = nil;
    Chengyu *validChengyu = nil;
    if(_characterSwitch.isOn){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        validChengyu = [[ChengyuHelper sharedInstance] checkValidByName:content andCharacter:theCharacter error:&error];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        BOOL includingTone = _toneSwitch.isOn;
        validChengyu = [[ChengyuHelper sharedInstance] checkValidByName:content andPinyin:thePinyin includingTone:includingTone error:&error];
    }
    if(validChengyu){
        currentChengyu = validChengyu;
        [self setContent];
    }else{
        NSString *errorInfo = nil;
        if(error){
            switch(error.code){
                case InvalidInputError: errorInfo = @"请输入内容"; break;
                case WrongLengthError: errorInfo = @"必须是四个字"; break;
                case NonExistentNameError: errorInfo = @"不是成语"; break;
                case UsedNameError: errorInfo = @"已经用过了"; break;
                default: errorInfo = @"未知错误";
            }
        }else{
            NSLog(@"error is still nil");
            errorInfo = @"未知错误";
        }
        [self setContentWithText:errorInfo];
    }
}

- (void)setContent {
    if(currentChengyu){
        _questionLabel.text = currentChengyu.name;
        _detailLabel.text = currentChengyu.meaning;
    }
}

- (void)setContentWithText:(NSString *)text {
    _questionLabel.text = text;
}

- (IBAction)backgroundTap:(id)sender {
    [_answerText resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 100;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
