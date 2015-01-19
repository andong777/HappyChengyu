//
//  ChengyuDetailViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/17.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ChengyuDetailViewController.h"
#import "FavoritesHelper.h"
#import "Chengyu.h"
#import <ChameleonFramework/Chameleon.h>

@interface ChengyuDetailViewController() {
    UIColor *textColor;
}

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *pinyinText;
@property (weak, nonatomic) IBOutlet UITextView *meaningText;
@property (weak, nonatomic) IBOutlet UITextView *sourceText;
@property (weak, nonatomic) IBOutlet UITextView *exampleText;
@property (weak, nonatomic) IBOutlet UILabel *exampleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *meaningLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *meaningToTitleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sourceToMeaningConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exampleToSourceConstraint;
@property (strong, nonatomic) NSLayoutConstraint *exampleToMeaningConstraint;

@end

@implementation ChengyuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.color){
        self.view.backgroundColor = self.color;
        textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.color isFlat:YES];
    }
    _exampleToMeaningConstraint = [NSLayoutConstraint constraintWithItem:_exampleText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_meaningText attribute:NSLayoutAttributeBottom multiplier:1 constant:50];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([[FavoritesHelper sharedInstance] hasFavorite:_chengyu]){
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }else{
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
    
    _nameText.text = _chengyu.name;
    _nameText.textColor = textColor;
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _pinyinText.textColor = textColor;
    _meaningText.text = _chengyu.meaning;
    _meaningText.textColor = textColor;
    _meaningLabel.textColor = textColor;
    _sourceLabel.textColor = textColor;
    _sourceText.text = _chengyu.source;
    _sourceText.textColor = textColor;
    _exampleLabel.textColor = textColor;
    _exampleText.text = _chengyu.example;
    _exampleText.textColor = textColor;
    
    if(_chengyu.source){
        if(!_chengyu.example){
            _exampleLabel.hidden = YES;
            _exampleText.hidden = YES;
            _sourceToMeaningConstraint.constant = 50;
        }
    }else{
        if(!_chengyu.example){
            _sourceLabel.hidden = YES;
            _sourceText.hidden = YES;
            _exampleLabel.hidden = YES;
            _exampleText.hidden = YES;
            _meaningToTitleConstraint.constant = 80;
        }else{
            _sourceLabel.hidden = YES;
            _sourceText.hidden = YES;
            [self.view removeConstraint:_exampleToSourceConstraint];
            [self.view addConstraint:_exampleToMeaningConstraint];
        }
    }

}

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
