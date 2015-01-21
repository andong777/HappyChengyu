//
//  MainViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"
#import "Constants.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *characterSwitch;
@property (weak, nonatomic) IBOutlet UILabel *toneLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _startButton.layer.cornerRadius = 10;
    _startButton.layer.borderWidth = 1;
    _startButton.layer.borderColor = _startButton.currentTitleColor.CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *includeCharacter = [defaults objectForKey:kCharacter];
    if(includeCharacter && [includeCharacter boolValue]){
        _characterSwitch.on = YES;
        _toneLabel.hidden = YES;
        _toneSwitch.hidden = YES;
    }else{
        _characterSwitch.on = NO;
        _toneLabel.hidden = NO;
        _toneSwitch.hidden = NO;
        NSNumber *includeTone = [defaults objectForKey:kTone];
        if(includeTone && [includeTone boolValue]){
            _toneSwitch.on = YES;
        }else{
            _toneSwitch.on = NO;
        }
    }
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender {
    if(sender.isOn){
        _toneLabel.hidden = YES;
        _toneSwitch.hidden = YES;
    }else{
        _toneLabel.hidden = NO;
        _toneSwitch.hidden = NO;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"StartSegue"]){
        GameViewController *vc = segue.destinationViewController;
        vc.includeCharacter = _characterSwitch.isOn;
        vc.includeTone = !_characterSwitch.isOn && _toneSwitch.isOn;
    }
}

@end
