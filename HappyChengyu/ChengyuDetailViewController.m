//
//  ChengyuDetailViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ChengyuDetailViewController.h"
#import "Chengyu.h"

@interface ChengyuDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *pinyinText;
@property (weak, nonatomic) IBOutlet UITextView *meaningText;
@property (weak, nonatomic) IBOutlet UITextView *sourceText;
@property (weak, nonatomic) IBOutlet UITextView *exampleText;
@end

@implementation ChengyuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _nameText.text = _chengyu.name;
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _meaningText.text = _chengyu.meaning;
    _sourceText.text = _chengyu.source;
    _exampleText.text = _chengyu.example;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
