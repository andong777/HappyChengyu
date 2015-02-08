//
//  FavoritesViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ChengyuDetailViewController.h"
#import "FavoritesHelper.h"
#import "Chengyu.h"
#import <ChameleonFramework/Chameleon.h>

@interface FavoritesViewController (){
    NSDictionary *_favorites;
    NSMutableDictionary *_colors;
}

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _favorites = [FavoritesHelper sharedInstance].favorites;
    NSLog(@"favorites: %lu", (unsigned long)[_favorites count]);
    _colors = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadData];
}

- (void)reloadData {
    _favorites = [FavoritesHelper sharedInstance].favorites;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [_favorites count];
    if(count > 0)   return count;
    
    // Display a message when the table is empty
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = @"您还没有添加任何收藏";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:24];
    [messageLabel sizeToFit];
    
    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self tableView:tableView titleForHeaderInSection:section];
    return [[_favorites valueForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChengyuCellReuseIdentifier" forIndexPath:indexPath];
    NSString *key = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    Chengyu *chengyu = [[_favorites valueForKey:key] objectAtIndex:indexPath.row];
    cell.textLabel.text = chengyu.name;
    cell.detailTextLabel.text = [chengyu.pinyin componentsJoinedByString:@" "];
    UIColor *sectionColor = [_colors valueForKey:key];
    if(!sectionColor){
        sectionColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
        [_colors setValue:sectionColor forKey:key];
    }
    cell.backgroundColor = sectionColor;
    cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:sectionColor isFlat:YES];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[_favorites allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sortedKeys = [[_favorites allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *key = [self tableView:tableView titleForHeaderInSection:indexPath.section];
        Chengyu *chengyu = [_favorites[key] objectAtIndex:indexPath.row];
        [[FavoritesHelper sharedInstance] removeFavorite:chengyu];
        [self reloadData];
    }
}


#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    NSString *key = [self tableView:tableView titleForHeaderInSection:section];
    UIColor *sectionColor = [_colors valueForKey:key];
    if(!sectionColor){
        sectionColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
        [_colors setValue:sectionColor forKey:key];
    }
    NSString *lastKey = section > 0 ? [self tableView:tableView titleForHeaderInSection:section - 1] : nil;
    UIColor *lastSectionColor = [_colors valueForKey:lastKey];
    if(!lastSectionColor){
        lastSectionColor = [UIColor flatWhiteColor];
    }
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.contentView.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:header.bounds andColors:@[lastSectionColor, sectionColor]];
    header.contentView.backgroundColor = sectionColor;
    header.textLabel.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:sectionColor isFlat:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChengyuDetailViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *key = [self tableView:self.tableView titleForHeaderInSection:indexPath.section];
    vc.chengyu = [_favorites[key] objectAtIndex:indexPath.row];
    vc.color = _colors[key];
    vc.fromFavorite = YES;
}

@end
