//
//  ViewerViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ChengyuSelectViewController.h"
#import "ChengyuDetailViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface ChengyuSelectViewController (){
    NSMutableArray *chengyus;
}

@end

@implementation ChengyuSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    chengyus = [[[ChengyuHelper sharedInstance] findAllWithFirstCharacter:_firstCharacter] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ChengyuSelectedSegue"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ChengyuDetailViewController *vc = segue.destinationViewController;
        vc.chengyu = [chengyus objectAtIndex:indexPath.row];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chengyus count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _firstCharacter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChengyuCellReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Chengyu *chengyu = [chengyus objectAtIndex:indexPath.row];
    cell.textLabel.text = chengyu.name;
    cell.detailTextLabel.text = [chengyu.pinyin componentsJoinedByString:@" "];
    return cell;
}

@end
