//
//  SettingsViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/9.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *characterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *readingSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *speakerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *wordsSwitch;

- (IBAction)switchCharacter:(UISwitch *)sender;
- (IBAction)switchTone:(UISwitch *)sender;
- (IBAction)switchReading:(UISwitch *)sender;
- (IBAction)switchSpeaker:(UISegmentedControl *)sender;
- (IBAction)switchWords:(UISwitch *)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *includeCharacter = [defaults objectForKey:kCharacter];
    if(includeCharacter && [includeCharacter boolValue]){
        _characterSwitch.on = YES;
        _toneSwitch.enabled = NO;
        _toneSwitch.on = YES;
    }else{
        _characterSwitch.on = NO;
        _toneSwitch.enabled = YES;
        NSNumber *includeTone = [defaults objectForKey:@"Tone"];
        if(includeTone && [includeTone boolValue]){
            _toneSwitch.on = YES;
        }else{
            _toneSwitch.on = NO;
        }
    }
    NSNumber *noReading = [defaults objectForKey:kNoReading];
    if(noReading && [noReading boolValue]){
        _readingSwitch.on = NO;
        _speakerSwitch.enabled = NO;
    }else{
        _readingSwitch.on = YES;
        _speakerSwitch.enabled = YES;
    }
    NSString *speaker = [defaults stringForKey:kSpeaker];
    if([speaker isEqualToString:@"man"]){
        _speakerSwitch.selectedSegmentIndex = 0;
    }else if ([speaker isEqualToString:@"child"]){
        _speakerSwitch.selectedSegmentIndex = 2;
    }else{
        _speakerSwitch.selectedSegmentIndex = 1; // woman by default
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchCharacter:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(sender.isOn) forKey:kCharacter];
    if(sender.isOn){
        _toneSwitch.on = YES;
        [defaults setObject:@(YES) forKey:kTone];
        _toneSwitch.enabled = NO;
    }else{
        _toneSwitch.enabled = YES;
    }
}

- (IBAction)switchTone:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(sender.isOn) forKey:kTone];
}

- (IBAction)switchReading:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(sender.isOn) forKey:kNoReading];
    if(sender.isOn){
        _speakerSwitch.enabled = YES;
    }else{
        _speakerSwitch.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoiceSettingsChanged" object:self];
}

- (IBAction)switchSpeaker:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(sender.selectedSegmentIndex == 0){
        [defaults setObject:@"man" forKey:kSpeaker];
    }else if(sender.selectedSegmentIndex == 2){
        [defaults setObject:@"child" forKey:kSpeaker];
    }else{
        [defaults setObject:@"woman" forKey:kSpeaker];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoiceSettingsChanged" object:self];
}

- (IBAction)switchWords:(UISwitch *)sender {
    if(sender.isOn){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"敬请期待" message:@"成语接龙时使用四字词语，\n更好玩，更易玩！\n后续更新会加入此功能，敬请期待！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [sender setOn:NO animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2){
        if(indexPath.row == 0){
            NSString *appURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"960147648"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
        }else if(indexPath.row == 1){
            dispatch_async(dispatch_queue_create("share", NULL), ^{
                NSArray *activityItems = @[[NSString stringWithFormat:@"《开心成语接龙》是首个使用语音玩成语接龙的iOS应用。它能听懂你说的成语，并以各种人声读出答案，更真实、更方便，免去了同类应用打字的麻烦。它还具有成语学习功能，支持成语大全和成语搜索两种方法查询，成语释义丰富，支持收藏功能。"]];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:activityController  animated:YES completion:nil];
                });
                
            });
        }
    }
}


@end
