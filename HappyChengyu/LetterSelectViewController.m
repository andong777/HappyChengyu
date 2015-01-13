//
//  FirstLetterSelectViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "LetterSelectViewController.h"
#import "CharacterSelectViewController.h"
#import "CustomCell.h"
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

    startSet = [NSMutableOrderedSet orderedSetWithCapacity:26];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *firstLetter = [cy.abbr substringToIndex:1];
        [startSet addObject:firstLetter];
    }
    [startSet sortUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
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
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [startSet objectAtIndex:indexPath.row];
    return cell;
}

@end
