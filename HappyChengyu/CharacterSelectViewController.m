//
//  CharacterSelectViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "CharacterSelectViewController.h"
#import "ChengyuSelectViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"
#import "CharacterCell.h"

@interface CharacterSelectViewController (){
    NSMutableOrderedSet *startSet;
}

@end

@implementation CharacterSelectViewController

static NSString * const reuseIdentifier = @"CellReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top = 20;
    [self.collectionView setContentInset:contentInset];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10);
    
    startSet = [NSMutableOrderedSet orderedSetWithCapacity:100];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *theLetter = [cy.abbr substringToIndex:1];
        if([theLetter isEqualToString:_firstLetter]){
            NSString *firstCharacter = [cy.name substringToIndex:1];
            [startSet addObject:firstCharacter];
        }
    }
//    self.title = _firstLetter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"CharacterSelectedSegue"]){
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        ChengyuSelectViewController *vc = segue.destinationViewController;
        vc.firstCharacter = [startSet objectAtIndex:indexPath.row];
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [startSet count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CharacterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [startSet objectAtIndex:indexPath.row];
    return cell;
}

@end
