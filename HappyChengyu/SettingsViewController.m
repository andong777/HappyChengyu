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

- (IBAction)switchCharacter:(UISwitch *)sender;
- (IBAction)switchTone:(UISwitch *)sender;
- (IBAction)switchReading:(UISwitch *)sender;
- (IBAction)switchSpeaker:(UISegmentedControl *)sender;

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
    NSNumber *reading = [defaults objectForKey:kReading];
    if(reading && [reading boolValue]){
        _readingSwitch.on = YES;
        _speakerSwitch.enabled = YES;
    }else{
        _readingSwitch.on = NO;
        _speakerSwitch.enabled = NO;
    }
    NSNumber *speaker = [defaults objectForKey:kSpeaker];
    if(speaker && [speaker boolValue]){
        _speakerSwitch.selectedSegmentIndex = 0;    // YES: man
    }else{
        _speakerSwitch.selectedSegmentIndex = 1;    // NO: woman
    }
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
    [defaults setObject:@(sender.isOn) forKey:kReading];
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
        [defaults setObject:@(YES) forKey:kSpeaker];
    }else{
        [defaults setObject:@(NO) forKey:kSpeaker];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoiceSettingsChanged" object:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2){
        if(indexPath.row == 0){
            NSString *appURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
        }else if(indexPath.row == 1){
            dispatch_async(dispatch_queue_create("share", NULL), ^{
                NSArray *activityItems = @[[NSString stringWithFormat:@"《开心成语接龙》是一个通过语音玩接龙的iOS应用，还可以查询和学习成语哦！"]];
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
