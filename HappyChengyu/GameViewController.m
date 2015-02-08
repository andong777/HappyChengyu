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
#import <iflyMSC/IFlySpeechSynthesizerDelegate.h>
#import <iflyMSC/IFlySpeechSynthesizer.h>
#import <iflyMSC/IFlyRecognizerViewDelegate.h>
#import <iflyMSC/IFlyRecognizerView.h>
#import <iflyMSC/IFlySpeechConstant.h>
#import <iflyMSC/IFlySpeechError.h>
#import "Constants.h"

@interface GameViewController ()
<IFlySpeechSynthesizerDelegate, IFlyRecognizerViewDelegate, UIAlertViewDelegate> {
    Chengyu *currentChengyu;
    NSDate *startTime;
    NSUInteger chances;
    IFlySpeechSynthesizer *_iFlySpeechSynthesizer;
    IFlyRecognizerView *_iflyRecognizerView;
    CGRect originalFrame;
    NSInteger keyboardMovement;
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
- (IBAction)clickAddOrRemove:(id)sender;
- (IBAction)clickRecord:(id)sender;
- (IBAction)clickQuit:(id)sender;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSpeechSynthesizer];
    [self setupSpeechRecognizer];
    [self registerForKeyboardNotifications];
    
    _detailSwitch.selectedSegmentIndex = 0;
    _detailText.layer.cornerRadius = 5;
    _detailText.layer.borderWidth = 1;
    _detailText.layer.borderColor = [UIColor blueColor].CGColor;
    _checkButton.layer.cornerRadius = 10;
    _checkButton.layer.borderWidth = 1;
    _checkButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    [self doRestart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    originalFrame = self.view.frame;
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doRestart {
    NSLog(@"restart");
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
    Chengyu *validChengyu = [self checkText:content error:&error];
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
            case IncorrectStartError: errorInfo = @"成语首字不匹配"; break;
            default: errorInfo = @"未知错误";
        }
        [self setErrorInfo:errorInfo];
    }
}

- (Chengyu *)checkText:(NSString *)text error:(NSError **)error {
    Chengyu *result = nil;
    if(_includeCharacter){
        NSString *theCharacter = [currentChengyu.name substringFromIndex:[currentChengyu.name length] - 1];
        result = [[ChengyuHelper sharedInstance] checkValidByName:text andCharacter:theCharacter error:error];
    }else{
        NSString *thePinyin = [currentChengyu.pinyin objectAtIndex:[currentChengyu.pinyin count] - 1];
        result = [[ChengyuHelper sharedInstance] checkValidByName:text andPinyin:thePinyin includingTone:_includeTone error:error];
    }
    return result;
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
        NSLog(@"%f", timeInterval);
        ResultViewController *vc = segue.destinationViewController;
        vc.timeInterval = timeInterval;
        // 用户退出sender为退出按钮，程序无法接龙主动退出sender为self
        if(sender == self){
            vc.extraInfo = @"找不到可以接龙的词语了";
        }
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定重新开始吗？" message:@"重新开始会清空本次的接龙记录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
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

- (IBAction)clickQuit:(id)sender {
    [self performSegueWithIdentifier:@"EndSegue" sender:sender];
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

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.view.frame = originalFrame;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3];
    int distance = self.view.frame.size.height - _answerText.frame.origin.y - _answerText.frame.size.height;
    keyboardMovement = kbSize.height > distance ? kbSize.height - distance : 0;
    self.view.frame = CGRectOffset(self.view.frame, 0, -1 * keyboardMovement);
    [UIView commitAnimations];
    
    self.navigationItem.title = currentChengyu.name;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3];
    self.view.frame = CGRectOffset(self.view.frame, 0, keyboardMovement);
    [UIView commitAnimations];
    
    static NSString *fixedTitle = @"成语接龙";
    self.navigationItem.title = fixedTitle;
}

- (void)setupSpeechSynthesizer {
    BOOL noReading = [[NSUserDefaults standardUserDefaults] boolForKey:kNoReading];
    NSString *speaker = [[NSUserDefaults standardUserDefaults] stringForKey:kSpeaker];
    if(!noReading){
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
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVoiceSettingsChanged:) name:@"VoiceSettingsChanged" object:nil];
}

- (void)onVoiceSettingsChanged:(NSNotification *)notification {
    BOOL noReading = [[NSUserDefaults standardUserDefaults] boolForKey:kNoReading];
    NSString *speaker = [[NSUserDefaults standardUserDefaults] stringForKey:kSpeaker];
    if(!noReading && !_iFlySpeechSynthesizer){
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        _iFlySpeechSynthesizer.delegate = self;
        [_iFlySpeechSynthesizer setParameter:@"20" forKey:[IFlySpeechConstant SPEED]];
        [_iFlySpeechSynthesizer setParameter:@"100" forKey: [IFlySpeechConstant VOLUME]];
        NSString *voice = @"xiaoyan";
        if([speaker isEqualToString:@"man"]){
            voice = @"xiaoyu";
        }else if([speaker isEqualToString:@"child"]){
            voice = @"vinn";
        }
        [_iFlySpeechSynthesizer setParameter:voice forKey: [IFlySpeechConstant VOICE_NAME]];
        [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
        [_iFlySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    }else if(!noReading){
        NSString *voice = @"xiaoyan";
        if([speaker isEqualToString:@"man"]){
            voice = @"xiaoyu";
        }else if([speaker isEqualToString:@"child"]){
            voice = @"vinn";
        }
        [_iFlySpeechSynthesizer setParameter:voice forKey: [IFlySpeechConstant VOICE_NAME]];
    }else{
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
    if(_answerText.text){
        NSError *error;
        Chengyu *validChengyu = [self checkText:_answerText.text error:&error];
        if(validChengyu){
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            [hud hide:YES afterDelay:1];
            currentChengyu = validChengyu;
            [self setContent];
            [self doAnswer];
        }
    }
}

- (void)onError: (IFlySpeechError *) error {
//    [self setErrorInfo:@"识别结束"];
    NSLog(@"recognize error: %@", error.errorDesc);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex){
        case 1:
            [self doRestart];
            break;
        default:
            break;  // cancelled
    }
}

@end
