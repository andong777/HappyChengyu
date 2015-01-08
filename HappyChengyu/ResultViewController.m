//
//  ResultViewController.m
//  HappyChengyu
//
//  Created by andong on 15/1/8.
//  Copyright (c) 2015年 AN Dong. All rights reserved.
//

#import "ResultViewController.h"
#import "ChengyuHelper.h"
#import "Chengyu.h"

@interface ResultViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lengthText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UILabel *percentText;
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 20;
    [self.tableView setContentInset:contentInset];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray *chengyus = [ChengyuHelper sharedInstance].appearedList;
    _lengthText.text = [NSString stringWithFormat:@"%lu", (unsigned long)[chengyus count]];
    NSMutableArray *chengyuNames = [NSMutableArray arrayWithCapacity:[chengyus count]];
    for(Chengyu *cy in chengyus){
        [chengyuNames addObject:cy.name];
    }
    _contentText.text = [chengyuNames componentsJoinedByString:@" → "];
    NSInteger ti = (NSInteger)_timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    _timeText.text = [NSString stringWithFormat:@"用时：%ld分 %ld秒", (long)minutes, (long)seconds];
    _percentText.text = [NSString stringWithFormat:@"你打败了 %d%% 的人", 99];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
