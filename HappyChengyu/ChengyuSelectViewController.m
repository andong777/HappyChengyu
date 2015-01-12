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
    NSMutableOrderedSet *startSet;
}

@end

@implementation ChengyuSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startSet = [NSMutableOrderedSet orderedSetWithCapacity:1000];
    for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
        NSString *theCharacter = [cy.name substringToIndex:1];
        if([theCharacter isEqualToString:_firstCharacter]){
            [startSet addObject:cy.name];
        }
    }
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
        NSString *chengyuName = [startSet objectAtIndex:indexPath.row];
        Chengyu *theChengyu = [[ChengyuHelper sharedInstance] getByName:chengyuName];
        ChengyuDetailViewController *vc = segue.destinationViewController;
        vc.chengyu = theChengyu;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [startSet count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _firstCharacter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChengyuCellReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [startSet objectAtIndex:indexPath.row];
    return cell;
}

@end
