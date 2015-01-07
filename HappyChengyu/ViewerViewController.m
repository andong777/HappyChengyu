//
//  ViewerViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/7.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ViewerViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface ViewerViewController (){
    NSMutableOrderedSet *startSet;
}

@end

@implementation ViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    startSet = [NSMutableOrderedSet orderedSetWithCapacity:1000];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *firstCharacter = [cy.name substringToIndex:1];
        [startSet addObject:firstCharacter];
    }
    NSLog(@"length: %lu", [startSet count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [startSet count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [startSet objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *startCharacter = [startSet objectAtIndex:section];
    NSArray *filteredArray = [[ChengyuHelper sharedInstance] findWithFirstCharacter:startCharacter];
    return [filteredArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChengyuCellReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Chengyu *theChengyu = [[ChengyuHelper sharedInstance].chengyuList objectAtIndex:indexPath.row];
    cell.textLabel.text = theChengyu.name;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
