//
//  ViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/4.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "GameViewController.h"
#import "ChengyuHelper.h"
#import "FavoritesHelper.h"
#import "Chengyu.h"
#import "ResultViewController.h"
#import <MBProgressHUD.h>
#import <ChameleonFramework/Chameleon.h>
#import <iflyMSC/IFlySpeechSynthesizerDelegate.h>
#import <iflyMSC/IFlySpeechSynthesizer.h>
#import <iflyMSC/IFlyRecognizerViewDelegate.h>
#import <iflyMSC/IFlyRecognizerView.h>
#import <iflyMSC/IFlySpeechConstant.h>
#import <iflyMSC/IFlySpeechError.h>
#import "Constants.h"

@interface GameViewController ()<IFlySpeechSynthesizerDelegate, IFlyRecognizerViewDelegate> {
    Chengyu *currentChengyu;
    NSDate *startTime;
    NSUInteger chances;
    IFlySpeechSynthesizer *_iFlySpeechSynthesizer;
    IFlyRecognizerView *_iflyRecognizerView;
}

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *pinyinText;
@property (weak, nonatomic) IBOutlet UITextView *detailText;
@property (weak, nonatomic) IBOutlet UITextField *answerText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *detailSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *hintButton;

- (IBAction)switchDetail:(UISegmentedControl *)sender;
- (IBAction)clickCheck:(UIButton *)sender;
- (IBAction)clickRestart:(UIButton *)sender;
- (IBAction)clickHint:(UIButton *)sender;
- (IBAction)clickQuit:(id)sender;
- (IBAction)clickAddOrRemove:(id)sender;
- (IBAction)clickRecord:(id)sender;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSpeechSynthesizer];
    [self setupSpeechRecognizer];
    
    _detailSwitch.selectedSegmentIndex = 0;
    [self doRestart];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([[FavoritesHelper sharedInstance] hasFavorite:currentChengyu]){
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }else{
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRestart {
    chances = 3;
    _hintButton.enabled = YES;
    [_hintButton setTitle:[NSString stringWithFormat:@"提示(%lu)", (unsigned long)chances] forState:UIControlStateNormal];
    [[ChengyuHelper sharedInstance] reloadData];
    currentChengyu = [[ChengyuHelper sharedInstance] randomWithRemove:YES];
    startTime = [NSDate date];
    [_iFlySpeechSynthesizer startSpeaking:currentChengyu.name];
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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        [hud hide:YES afterDelay:1];
        currentChengyu = validChengyu;
        [self setContent];
        [self doAnswer];
    }else{
        NSString *errorInfo = nil;
        switch(error.code){
            case InvalidInputError: errorInfo = @"请输入内容"; break;
            case WrongLengthError: errorInfo = @"必须是四个字"; break;
            case NonExistentNameError: errorInfo = @"不是成语"; break;
            case UsedNameError: errorInfo = @"已经用过了"; break;
            default: errorInfo = @"未知错误";
        }
        [self setErrorInfo:errorInfo];
    }
}

- (void)doAnswer {
    _checkButton.enabled = NO;
    [_spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.5];    // to display user's answer
        Chengyu *answer = nil;
        NSArray *candidatesAfterAnswer = nil;
        if(_includeCharacter){
            NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
            answer = [[ChengyuHelper sharedInstance] findNextWithFirstCharacter:theCharacter andRemove:YES];
            NSString *answerCharacter = [answer.name substringFromIndex:[answer.name length] - 1];
            candidatesAfterAnswer = [[ChengyuHelper sharedInstance] findAllWithFirstCharacter:answerCharacter];
        }else{
            NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
            answer = [[ChengyuHelper sharedInstance] findNextWithFirstPinyin:thePinyin includingTone:_includeTone andRemove:YES];
            NSString *answerPinyin = [answer.pinyin objectAtIndex:[answer.pinyin count] - 1];
            candidatesAfterAnswer = [[ChengyuHelper sharedInstance] findAllWithFirstPinyin:answerPinyin includingTone:_includeTone];
        }
        [NSThread sleepForTimeInterval:0.5];    // to simulate thinking
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinner stopAnimating];
            _checkButton.enabled = YES;
            if(answer){
                currentChengyu = answer;
                [_iFlySpeechSynthesizer startSpeaking:answer.name];
                [self setContent];
            }
            if(!answer || !candidatesAfterAnswer || [candidatesAfterAnswer count] == 0){
                [self performSegueWithIdentifier:@"EndSegue" sender:self];
            }
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"EndSegue"]){
        NSDate *stopTime = [NSDate date];
        NSTimeInterval timeInterval = [stopTime timeIntervalSinceDate:startTime];
        ResultViewController *vc = segue.destinationViewController;
        vc.timeInterval = timeInterval;
    }
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
    chances--;
    [_hintButton setTitle:[NSString stringWithFormat:@"提示(%lu)", (unsigned long)chances] forState:UIControlStateNormal];
    if(chances <= 0){
        _hintButton.enabled = NO;
    }
    Chengyu *answer = nil;
    if(_includeCharacter){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstCharacter:theCharacter andRemove:NO];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        answer = [[ChengyuHelper sharedInstance] findNextWithFirstPinyin:thePinyin includingTone:_includeTone andRemove:NO];
    }
    if(answer){
        _answerText.text = answer.name;
    }
}

- (IBAction)clickQuit:(id)sender {
    [self performSegueWithIdentifier:@"EndSegue" sender:self];
}

- (IBAction)clickAddOrRemove:(id)sender {
    FavoritesHelper *helper = [FavoritesHelper sharedInstance];
    if([helper hasFavorite:currentChengyu]){
        [helper removeFavorite:currentChengyu];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }else{
        [helper addFavorite:currentChengyu];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
}

- (IBAction)clickRecord:(id)sender {
    _answerText.text = nil;
    [_iflyRecognizerView start];
}

- (void)setContent {
    if(currentChengyu){
        _nameText.text = currentChengyu.name;
        _pinyinText.text = [currentChengyu.pinyin componentsJoinedByString:@" "];
        NSString *text = nil;
        switch(_detailSwitch.selectedSegmentIndex){
            case 0: text = currentChengyu.meaning; break;
            case 1: text = currentChengyu.source; break;
            case 2: text = currentChengyu.example; break;
            default: text = currentChengyu.meaning;
        }
        _detailText.text = (text && [text length]>0) ? text : @"未收录";
        
        if([[FavoritesHelper sharedInstance] hasFavorite:currentChengyu]){
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
        }else{
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
        }
    }
    _answerText.text = nil;
}

- (void)setErrorInfo:(NSString *)errorInfo {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = errorInfo;
    [hud hide:YES afterDelay:1];
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
    const int movementDistance = 80;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)setupSpeechSynthesizer {
    BOOL reading = [[[NSUserDefaults standardUserDefaults] objectForKey:kReading] boolValue];
    BOOL speaker = [[[NSUserDefaults standardUserDefaults] objectForKey:kSpeaker] boolValue];
    if(reading){
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        _iFlySpeechSynthesizer.delegate = self;
        [_iFlySpeechSynthesizer setParameter:@"20" forKey:[IFlySpeechConstant SPEED]];
        [_iFlySpeechSynthesizer setParameter:@"80" forKey: [IFlySpeechConstant VOLUME]];
        [_iFlySpeechSynthesizer setParameter:speaker ? @"xiaoyu" : @"xiaoyan" forKey: [IFlySpeechConstant VOICE_NAME]];
        [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
        [_iFlySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVoiceSettingsChanged:) name:@"VoiceSettingsChanged" object:nil];
}

- (void)onVoiceSettingsChanged:(NSNotification *)notification {
    BOOL reading = [[[NSUserDefaults standardUserDefaults] objectForKey:kReading] boolValue];
    NSString *speaker = [[NSUserDefaults standardUserDefaults] stringForKey:kSpeaker];
    if(reading && !_iFlySpeechSynthesizer){
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        _iFlySpeechSynthesizer.delegate = self;
        [_iFlySpeechSynthesizer setParameter:@"20" forKey:[IFlySpeechConstant SPEED]];
        [_iFlySpeechSynthesizer setParameter:@"80" forKey: [IFlySpeechConstant VOLUME]];
        NSString *voice = @"xiaoyan";
        if([speaker isEqualToString:@"man"]){
            voice = @"xiaoyu";
        }else if([speaker isEqualToString:@"child"]){
            voice = @"vinn";
        }
        [_iFlySpeechSynthesizer setParameter:voice forKey: [IFlySpeechConstant VOICE_NAME]];
        [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
        [_iFlySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    }else if(reading){
        NSString *voice = @"xiaoyan";
        if([speaker isEqualToString:@"man"]){
            voice = @"xiaoyu";
        }else if([speaker isEqualToString:@"child"]){
            voice = @"vinn";
        }
        [_iFlySpeechSynthesizer setParameter:voice forKey: [IFlySpeechConstant VOICE_NAME]];
    }else if(!reading && _iFlySpeechSynthesizer){
        _iFlySpeechSynthesizer = nil;
    }
}

- (void) onCompleted:(IFlySpeechError *) error {
    NSLog(@"play done");
}

- (void)setupSpeechRecognizer {
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center]; _iflyRecognizerView.delegate = self;
    [_iflyRecognizerView setParameter:@"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter:@"0" forKey:@"asr_ptt"]; // 无标点
    [_iflyRecognizerView setParameter:@"1000" forKey:@"vad_eos"]; // 关闭听写时间
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iflyRecognizerView setParameter:nil forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
}

- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    _answerText.text = [NSString stringWithFormat:@"%@%@", _answerText.text, result];
}

- (void)onError: (IFlySpeechError *) error {
    [self setErrorInfo:@"识别结束"];
    NSLog(@"recognize error: %@", error.errorDesc);
}

@end
