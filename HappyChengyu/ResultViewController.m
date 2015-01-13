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

@interface ResultViewController (){
    NSInteger length;
    NSInteger minutes;
    NSInteger seconds;
    NSInteger percentage;
}

@property (weak, nonatomic) IBOutlet UILabel *lengthText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UILabel *percentText;
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *chengyus = [ChengyuHelper sharedInstance].appearedList;
    length = [chengyus count];
    _lengthText.text = [NSString stringWithFormat:@"%ld", (long)length];
    NSMutableArray *chengyuNames = [NSMutableArray arrayWithCapacity:length];
    for(Chengyu *cy in chengyus){
        [chengyuNames addObject:cy.name];
    }
    _contentText.text = [chengyuNames componentsJoinedByString:@" → "];
    NSInteger ti = (NSInteger)_timeInterval;
    seconds = ti % 60;
    minutes = (ti / 60) % 60;
    _timeText.text = [NSString stringWithFormat:@"用时：%ld分 %ld秒", (long)minutes, (long)seconds];
    // TODO: 真正实现获取百分比
    percentage = length / 3 * 10;
    _percentText.text = [NSString stringWithFormat:@"你打败了 %ld%% 的人", (long)percentage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickShare:(id)sender {
    dispatch_async(dispatch_queue_create("share", NULL), ^{
        NSArray *activityItems = @[[NSString stringWithFormat:@"我在《开心成语接龙》玩成语接龙，接龙长度达到%ld，用时%ld分%ld秒，打败了%ld%%的人。", (long)length, (long)minutes, (long)seconds, (long)percentage]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityController  animated:YES completion:nil];
        });
    });
}

- (IBAction)clickReturn:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
