//
//  ViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "AnswerViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface AnswerViewController () {
    Chengyu *currentChengyu;
}

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *pinyinText;
@property (weak, nonatomic) IBOutlet UITextView *detailText;
@property (weak, nonatomic) IBOutlet UITextField *answerText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *detailSwitcher;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)switchDetail:(UISegmentedControl *)sender;
- (IBAction)clickCheck:(UIButton *)sender;
- (IBAction)clickRestart:(UIButton *)sender;
- (IBAction)clickHint:(UIButton *)sender;

@end

@implementation AnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detailSwitcher.selectedSegmentIndex = 0;
    [self doRestart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRestart {
    [[ChengyuHelper sharedInstance] reloadData];
    currentChengyu = [[ChengyuHelper sharedInstance] random];
    [self setContent];
}

- (void)doCheck {
    NSString *content = _answerText.text;
    NSError *error = nil;
    Chengyu *validChengyu = nil;
    if(_includeCharacter){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        validChengyu = [[ChengyuHelper sharedInstance] checkValidByName:content andCharacter:theCharacter error:&error];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        validChengyu = [[ChengyuHelper sharedInstance] checkValidByName:content andPinyin:thePinyin includingTone:_includeTone error:&error];
    }
    if(validChengyu){
        currentChengyu = validChengyu;
        [self setContent];
        [self doAnswer];
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

- (void)doAnswer {
    [_spinner startAnimating];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:0.5];    // to display user's answer
        Chengyu *answer = nil;
        if(_includeCharacter){
            NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
            answer = [[ChengyuHelper sharedInstance] findNextWithFirstCharacter:theCharacter];
        }else{
            NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
            NSLog(@"pinyin: %@", thePinyin);
            answer = [[ChengyuHelper sharedInstance] findNextWithFirstPinyin:thePinyin includingTone:_includeTone];
        }
        [NSThread sleepForTimeInterval:0.5];    // to simulate thinking
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinner stopAnimating];
            if(answer){
                NSLog(@"%@", answer.name);
                currentChengyu = answer;
                [self setContent];
            }else{
                [self setContentWithText:@"找不到候选词"];
            }
        });
    });
}

- (IBAction)switchDetail:(UISegmentedControl *)sender {
    [self setContent];
}

- (IBAction)clickCheck:(UIButton *)sender {
    [_answerText resignFirstResponder];
    [self doCheck];
}

- (IBAction)clickRestart:(UIButton *)sender {
    [self doRestart];
}

- (IBAction)clickHint:(UIButton *)sender {
    [self doAnswer];
}

- (void)setContent {
    if(currentChengyu){
        _nameText.text = currentChengyu.name;
        _pinyinText.text = [currentChengyu.pinyin componentsJoinedByString:@" "];
        NSString *text = nil;
        switch(_detailSwitcher.selectedSegmentIndex){
            case 0: text = currentChengyu.meaning; break;
            case 1: text = currentChengyu.source; break;
            case 2: text = currentChengyu.example; break;
            default: text = currentChengyu.meaning;
        }
        _detailText.text = (text && [text length]>0) ? text : @"未收录";
    }else{
        _nameText.text = nil;
        _pinyinText.text = nil;
        _detailText.text = nil;
    }
    _answerText.text = nil;
}

- (void)setContentWithText:(NSString *)text {
    currentChengyu = nil;
    [self setContent];
    _nameText.text = text;
}

- (IBAction)backgroundTap:(id)sender {
    [_answerText resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self doCheck];
    return YES;
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
    const int movementDistance = 80;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
