//
//  FirstLetterSelectViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "LetterSelectViewController.h"
#import "CharacterSelectViewController.h"
#import "CharacterCell.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface LetterSelectViewController (){
    NSMutableOrderedSet *startSet;
}

@end

@implementation LetterSelectViewController

static NSString * const reuseIdentifier = @"CellReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top = 20;
    [self.collectionView setContentInset:contentInset];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10);
    
    startSet = [NSMutableOrderedSet orderedSetWithCapacity:26];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *firstLetter = [cy.abbr substringToIndex:1];
        [startSet addObject:firstLetter];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"LetterSelectedSegue"]){
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        CharacterSelectViewController *vc = segue.destinationViewController;
        vc.firstLetter = [startSet objectAtIndex:indexPath.row];
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [startSet count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CharacterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [startSet objectAtIndex:indexPath.row];
    return cell;
}

@end
