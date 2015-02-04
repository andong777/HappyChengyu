//
//  FirstLetterSelectViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "LetterSelectViewController.h"
#import "CharacterSelectViewController.h"
#import "LetterCell.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"
#import <VCTransitionsLibrary/CEExplodeAnimationController.h>
#import <ChameleonFramework/Chameleon.h>

@interface LetterSelectViewController ()<UINavigationControllerDelegate>{
    NSArray *letters;
}

@end

@implementation LetterSelectViewController

static NSString * const reuseIdentifier = @"CellReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableOrderedSet *startSet = [NSMutableOrderedSet orderedSetWithCapacity:26];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *firstLetter = [cy.abbr substringToIndex:1];
        [startSet addObject:firstLetter];
    }
//    [startSet sortUsingComparator:^(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
    letters = [startSet array];
    self.navigationController.delegate = self;
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
        vc.firstLetter = [letters objectAtIndex:indexPath.row];
        LetterCell *selectedCell = (LetterCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        vc.color = selectedCell.backgroundColor;
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [letters count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LetterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.label.text = [letters objectAtIndex:indexPath.row];
    UIColor *backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
    cell.backgroundColor = backgroundColor;
    cell.label.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:backgroundColor isFlat:YES];
    return cell;
}


#pragma mark <UINavigationControllerDelegate>

- (id<UIViewControllerAnimatedTransitioning>)navigationController:
(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation                                               fromViewController:(UIViewController *)fromVC                                                  toViewController:(UIViewController *)toVC {
    // reverse the animation for 'pop' transitions
//    CEExplodeAnimationController *animator = [CEExplodeAnimationController new];
//    animator.duration = 0.6;
//    animator.reverse = (operation == UINavigationControllerOperationPush);
//    return animator;
    return nil;
}

@end
