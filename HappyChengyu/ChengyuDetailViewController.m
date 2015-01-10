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

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *pinyinText;
@property (weak, nonatomic) IBOutlet UITextView *meaningText;
@property (weak, nonatomic) IBOutlet UITextView *sourceText;
@property (weak, nonatomic) IBOutlet UITextView *exampleText;

- (IBAction)clickAddOrRemove:(id)sender;
@end

@implementation ChengyuDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameText.text = _chengyu.name;
    _pinyinText.text = [_chengyu.pinyin componentsJoinedByString:@" "];
    _meaningText.text = _chengyu.meaning;
    _sourceText.text = _chengyu.source;
    _exampleText.text = _chengyu.example;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *favoriteButton = self.navigationItem.rightBarButtonItem;
    if([[FavoritesHelper sharedInstance] hasFavorite:_chengyu]){
        favoriteButton.tintColor = [UIColor blueColor];
    }else{
        favoriteButton.tintColor = [UIColor lightGrayColor];
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
