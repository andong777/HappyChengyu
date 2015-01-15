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
#import "TitleCell.h"
#import <ChameleonFramework/Chameleon.h>

@interface CharacterSelectViewController (){
    NSArray *characters;
    NSMutableArray *colorArray;
}

@end

@implementation CharacterSelectViewController

static NSString * const reuseIdentifier = @"CellReuseIdentifier";
static NSString * const headerReuseIdentifier = @"HeaderReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.headerReferenceSize = CGSizeMake(100, 25);
    [self.collectionView registerClass:[TitleCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier];
    
    NSMutableOrderedSet *startSet = [NSMutableOrderedSet orderedSet];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *theLetter = [cy.abbr substringToIndex:1];
        if([theLetter isEqualToString:_firstLetter]){
            NSString *firstCharacter = [cy.name substringToIndex:1];
            [startSet addObject:firstCharacter];
        }
    }
    characters = [startSet array];
    
    colorArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayOfColorsWithColorScheme:ColorSchemeAnalogous for:self.color                                                                                                 flatScheme:NO]];
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
        vc.firstCharacter = [characters objectAtIndex:indexPath.row];
        TitleCell *selectedCell = (TitleCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        vc.color = selectedCell.label.backgroundColor;
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [characters count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [characters objectAtIndex:indexPath.row];
    cell.label.backgroundColor = [colorArray objectAtIndex:indexPath.row % [colorArray count]];
    cell.label.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:cell.label.backgroundColor isFlat:YES];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        TitleCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
        headerView.label.text = _firstLetter;
        headerView.label.backgroundColor = self.color;
        headerView.label.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:headerView.label.backgroundColor isFlat:YES];
        return headerView;
    }
    return nil;
}

@end
