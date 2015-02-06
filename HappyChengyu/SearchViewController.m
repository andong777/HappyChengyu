//
//  SearchViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/12.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "SearchViewController.h"
#import "ChengyuDetailViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface SearchViewController ()<UISearchBarDelegate>{
    NSMutableArray *searchResults;
}

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = @"搜索成语、成语首字母缩写或单字";
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.showsCancelButton = YES;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    searchResults = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchReuseIdentifier" forIndexPath:indexPath];
    Chengyu *chengyu = [searchResults objectAtIndex:indexPath.row];
    NSMutableAttributedString *nameAttributedString = [[NSMutableAttributedString alloc] initWithString:chengyu.name attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    NSString *pinyin = [[[NSString alloc]
                        initWithData:
                        [[chengyu.pinyin componentsJoinedByString:@" "] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                        encoding:NSASCIIStringEncoding] uppercaseString];
    NSMutableAttributedString *pinyinAttributedString = [[NSMutableAttributedString alloc] initWithString:[chengyu.pinyin componentsJoinedByString:@" "] attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]}];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)", self.searchBar.text] options:kNilOptions error:nil];
    [regex enumerateMatchesInString:chengyu.name options:kNilOptions range:NSMakeRange(0, [chengyu.name length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [nameAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:subStringRange];
    }];
    [regex enumerateMatchesInString:pinyin options:kNilOptions range:NSMakeRange(0, [pinyin length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:1];
        [pinyinAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:subStringRange];
    }];
    cell.textLabel.attributedText = nameAttributedString;
    cell.detailTextLabel.attributedText = pinyinAttributedString;
    return cell;
}


#pragma mark - Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchResults removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    [searchBar resignFirstResponder];
    NSLog(@"you searched %@", searchText);
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        for(Chengyu *cy in [ChengyuHelper sharedInstance].chengyuList){
            // search name, abbreviation and pinyin.
//            if([cy.name containsString:searchText]){  // iOS 8 only
            if([cy.name rangeOfString:searchText].location != NSNotFound){
                [searchResults addObject:cy];
            }else if([cy.abbr caseInsensitiveCompare:searchText] == NSOrderedSame){
                [searchResults addObject:cy];
            }else{
                for(NSString *py in cy.pinyin){
                    if([py compare:searchText                                 options:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch] == NSOrderedSame){
                        [searchResults addObject:cy];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ChengyuDetailViewController *vc = segue.destinationViewController;
    vc.chengyu = [searchResults objectAtIndex:indexPath.row];
}

@end
