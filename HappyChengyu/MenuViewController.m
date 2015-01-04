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

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
- (IBAction)clickStart:(UIButton *)sender;

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
    Chengyu *one = [[ChengyuHelper sharedInstance] random];
    _questionLabel.text = one.name;
}
@end
