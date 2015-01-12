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
#import "CustomCell.h"

@interface CharacterSelectViewController (){
    NSMutableOrderedSet *startSet;
}

@end

@implementation CharacterSelectViewController

static NSString * const reuseIdentifier = @"CellReuseIdentifier";
static NSString * const headerReuseIdentifier = @"HeaderReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top = 20;
    [self.collectionView setContentInset:contentInset];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10);
    
    flowLayout.headerReferenceSize = CGSizeMake(100, 25);
    [self.collectionView registerClass:[CustomCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier];
    
    startSet = [NSMutableOrderedSet orderedSetWithCapacity:100];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *theLetter = [cy.abbr substringToIndex:1];
        if([theLetter isEqualToString:_firstLetter]){
            NSString *firstCharacter = [cy.name substringToIndex:1];
            [startSet addObject:firstCharacter];
        }
    }
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
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [startSet objectAtIndex:indexPath.row];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CustomCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
        headerView.label.text = _firstLetter;
        return headerView;
    }
    return nil;
}

@end
