//
//  MainViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "MainViewController.h"
#import "AnswerViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *characterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *toneSwitch;

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCharacterSwitch:(UISwitch *)sender {
    if(sender.isOn){
        _toneSwitch.On = YES;
        _toneSwitch.enabled = NO;
    }else{
        _toneSwitch.enabled = YES;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"StartSegue"]){
        AnswerViewController *vc = segue.destinationViewController;
        vc.includeCharacter = _characterSwitch.isOn;
        vc.includeTone = !_characterSwitch.isOn && _toneSwitch.isOn;
    }
}

@end