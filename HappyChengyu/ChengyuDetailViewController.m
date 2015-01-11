//
//  ChengyuDetailViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ChengyuDetailViewController.h"
#import "FavoritesHelper.h"
#import "Chengyu.h"

@interface ChengyuDetailViewController ()

@property (strong, nonatomic) UILabel *nameText;
@property (strong, nonatomic) UILabel *pinyinText;
@property (strong, nonatomic) UITextView *meaningText;
@property (strong, nonatomic) UITextView *sourceText;
@property (strong, nonatomic) UITextView *exampleText;

- (void)clickAddOrRemove:(id)sender;
@end

@implementation ChengyuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem.rightBarButtonItem setAction:@selector(clickAddOrRemove:)];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat beginHeight = 50;
    CGFloat smallGap = 20;
    CGFloat bigGap = 40;
    CGFloat nameHeight = 50;
    CGFloat pinyinHeight = 30;
    CGFloat meaningHeight = 80;
    CGFloat sourceHeight = 100;
    CGFloat exampleHeight = 100;
    
    CGRect nameFrame = CGRectMake(inset, beginHeight + smallGap, headerFrame.size.width - 2 * inset, nameHeight);
    _nameText = [[UILabel alloc] initWithFrame:nameFrame];
    _nameText.text = _chengyu.name;
    _nameText.textAlignment = NSTextAlignmentCenter;
    _nameText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.view addSubview:_nameText];
    
    CGRect pinyinFrame = CGRectMake(inset, nameFrame.origin.y + nameHeight + smallGap, headerFrame.size.width - 2 * inset, pinyinHeight);
    _pinyinText = [[UILabel alloc] initWithFrame:pinyinFrame];
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _pinyinText.textAlignment = NSTextAlignmentCenter;
    _pinyinText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:_pinyinText];
    
    CGRect meaningFrame = CGRectMake(inset, pinyinFrame.origin.y + pinyinHeight + bigGap, headerFrame.size.width - 2 * inset, meaningHeight);
    _meaningText = [[UITextView alloc] initWithFrame:meaningFrame];
    _meaningText.text = _chengyu.meaning;
    _meaningText.textAlignment = NSTextAlignmentLeft;
    _meaningText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.view addSubview:_meaningText];
    
    CGRect otherFrame = CGRectMake(inset, meaningFrame.origin.y + meaningHeight + bigGap, headerFrame.size.width - 2 * inset, sourceHeight);
    if(_chengyu.source && [_chengyu.source length]){
        _sourceText = [[UITextView alloc] initWithFrame:otherFrame];
        _sourceText.text = _chengyu.source;
        _sourceText.textAlignment = NSTextAlignmentLeft;
        _sourceText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.view addSubview:_sourceText];
        otherFrame.origin.y += sourceHeight + bigGap;
        otherFrame.size.height = exampleHeight;
    }
    
    if(_chengyu.example && [_chengyu.example length]){
        _exampleText = [[UITextView alloc] initWithFrame:otherFrame];
        _exampleText.text = _chengyu.example;
        _exampleText.textAlignment = NSTextAlignmentLeft;
        _exampleText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.view addSubview:_exampleText];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([[FavoritesHelper sharedInstance] hasFavorite:_chengyu]){
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }else{
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
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

- (IBAction)clickAddOrRemove:(id)sender {
    FavoritesHelper *helper = [FavoritesHelper sharedInstance];
    if([helper hasFavorite:_chengyu]){
        [helper removeFavorite:_chengyu];
        if(_fromFavorite){
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }else{
        [helper addFavorite:_chengyu];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }
}

@end
