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
#import <ChameleonFramework/Chameleon.h>
#import "Constants.h"

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
    self.view.backgroundColor = self.color;
    [self.navigationItem.rightBarButtonItem setAction:@selector(clickAddOrRemove:)];
    
    CGRect headerFrame = self.view.bounds;
    CGFloat inset = 15;
    CGFloat beginHeight = MAX(headerFrame.size.height / 8, 60);
    CGFloat bigGap = 20;
    CGFloat nameHeight = 40;
    CGFloat pinyinHeight = 20;
    CGFloat meaningHeight = MAX(headerFrame.size.height / 6, 50);
    CGFloat sourceHeight = MAX(headerFrame.size.height / 6, 60);
    CGFloat exampleHeight = MAX(headerFrame.size.height / 6, 60);
    CGFloat labelHeight = 20;
    
    CGRect nameFrame = CGRectMake(inset, beginHeight, headerFrame.size.width - 2 * inset, nameHeight);
    _nameText = [[UILabel alloc] initWithFrame:nameFrame];
    _nameText.text = _chengyu.name;
    _nameText.textAlignment = NSTextAlignmentCenter;
    _nameText.font = [UIFont fontWithName:kYueSongFontName size:32.f];
    [self setBackgroundAndTextColor:_nameText];
    [self.view addSubview:_nameText];
    
    CGRect pinyinFrame = CGRectMake(inset, nameFrame.origin.y + nameHeight, headerFrame.size.width - 2 * inset, pinyinHeight);
    _pinyinText = [[UILabel alloc] initWithFrame:pinyinFrame];
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _pinyinText.textAlignment = NSTextAlignmentCenter;
    _pinyinText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self setBackgroundAndTextColor:_pinyinText];
    [self.view addSubview:_pinyinText];
    
    CGRect meaningFrame = CGRectMake(inset, pinyinFrame.origin.y + pinyinHeight + bigGap, headerFrame.size.width - 2 * inset, meaningHeight);
    CGRect meaningLabelFrame = meaningFrame;
    meaningLabelFrame.origin.y -= labelHeight;
    meaningLabelFrame.size.height = labelHeight;
    UILabel *meaningLabel = [[UILabel alloc] initWithFrame:meaningLabelFrame];
    meaningLabel.text = @"含义";
    meaningLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [self setBackgroundAndTextColor:meaningLabel];
    [self.view addSubview:meaningLabel];
    _meaningText = [[UITextView alloc] initWithFrame:meaningFrame];
    _meaningText.text = _chengyu.meaning;
    _meaningText.textAlignment = NSTextAlignmentLeft;
    _meaningText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _meaningText.editable = NO;
    [self setBackgroundAndTextColor:_meaningText];
    [self.view addSubview:_meaningText];
    
    CGRect otherFrame = CGRectMake(inset, meaningFrame.origin.y + meaningHeight + bigGap, headerFrame.size.width - 2 * inset, sourceHeight);
    if(_chengyu.source && [_chengyu.source length]){
        CGRect otherLabelFrame = otherFrame;
        otherLabelFrame.origin.y -= labelHeight;
        otherLabelFrame.size.height = labelHeight;
        UILabel *otherLabel = [[UILabel alloc] initWithFrame:otherLabelFrame];
        otherLabel.text = @"出处";
        otherLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self setBackgroundAndTextColor:otherLabel];
        [self.view addSubview:otherLabel];
        _sourceText = [[UITextView alloc] initWithFrame:otherFrame];
        _sourceText.text = _chengyu.source;
        _sourceText.textAlignment = NSTextAlignmentLeft;
        _sourceText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _sourceText.editable = NO;
        [self setBackgroundAndTextColor:_sourceText];
        [self.view addSubview:_sourceText];
        
        otherFrame.origin.y += sourceHeight + bigGap;
        otherFrame.size.height = exampleHeight;
    }
    
    if(_chengyu.example && [_chengyu.example length]){
        CGRect otherLabelFrame = otherFrame;
        otherLabelFrame.origin.y -= labelHeight;
        otherLabelFrame.size.height = labelHeight;
        UILabel *otherLabel = [[UILabel alloc] initWithFrame:otherLabelFrame];
        otherLabel.text = @"例子";
        otherLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self setBackgroundAndTextColor:otherLabel];
        [self.view addSubview:otherLabel];
        _exampleText = [[UITextView alloc] initWithFrame:otherFrame];
        _exampleText.text = _chengyu.example;
        _exampleText.textAlignment = NSTextAlignmentLeft;
        _exampleText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _exampleText.editable = NO;
        [self setBackgroundAndTextColor:_exampleText];
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

- (void)clickAddOrRemove:(id)sender {
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

- (void) setBackgroundAndTextColor:(id)view {
    UIColor *clearColor = [UIColor clearColor];
    UIColor *contrastingColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.color isFlat:YES];
    [view setBackgroundColor:clearColor];
    [view setTextColor:contrastingColor];
}

@end
