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

@interface FavoritesViewController (){
    NSDictionary *_favorites;
}

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 20;
    [self.tableView setContentInset:contentInset];
    
    _favorites = [[FavoritesHelper sharedInstance] loadFavorites];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_favorites count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self tableView:tableView titleForHeaderInSection:section];
    return [_favorites[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChengyuCellReuseIdentifier" forIndexPath:indexPath];
    NSString *key = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    Chengyu *chengyu = [_favorites[key] objectAtIndex:indexPath.row];
    cell.textLabel.text = chengyu.name;
    cell.detailTextLabel.text = [chengyu.pinyin componentsJoinedByString:@" "];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_favorites allKeys];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[NSString stringWithFormat:@"%c", (char)(65+section)] uppercaseString];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *key = [self tableView:tableView titleForHeaderInSection:indexPath.section];
        Chengyu *chengyu = [_favorites[key] objectAtIndex:indexPath.row];
        [[FavoritesHelper sharedInstance] removeFavorite:chengyu];
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChengyuDetailViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *key = [self tableView:self.tableView titleForHeaderInSection:indexPath.section];
    vc.chengyu = [_favorites[key] objectAtIndex:indexPath.row];
}

@end
