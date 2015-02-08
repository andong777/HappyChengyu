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
@property (weak, nonatomic) IBOutlet UILabel *meaningLabel;
@property (weak, nonatomic) IBOutlet UITextView *meaningText;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UITextView *sourceText;
@property (weak, nonatomic) IBOutlet UILabel *exampleLabel;
@property (weak, nonatomic) IBOutlet UITextView *exampleText;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UITextView) NSArray *texts;

@end

@implementation ChengyuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.color){
        self.view.backgroundColor = self.color;
        textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.color isFlat:YES];
    }
    if([[FavoritesHelper sharedInstance] hasFavorite:_chengyu]){
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    }else{
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
    
    _nameText.textColor = textColor;
    _pinyinText.textColor = textColor;
    _meaningLabel.text = @"含\n义";
    _sourceLabel.text = @"出\n处";
    _exampleLabel.text = @"例\n子";
    for(UILabel *label in self.labels){
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.borderColor = textColor.CGColor;
        label.layer.borderWidth = 1;
        label.textColor = textColor;
    }
    for(UITextView *text in self.texts){
        text.layer.borderColor = textColor.CGColor;
        text.layer.borderWidth = 1;
        text.textColor = textColor;
        [text addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    }
    [self setContent];
}

- (void)dealloc {
    for(UITextView *text in self.texts){
        [text removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (void)setContent {
    _nameText.text = _chengyu.name;
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _meaningText.text = _chengyu.meaning;
    _sourceText.text = _chengyu.source;
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

@end
