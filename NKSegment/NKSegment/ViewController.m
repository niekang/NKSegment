//
//  ViewController.m
//  NKSegment
//
//  Created by niekang on 2019/4/8.
//  Copyright © 2019 xiangshang360. All rights reserved.
//

#import "ViewController.h"
#import "NKSegment.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NKSegment *segment = [[NKSegment alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    segment.titles = @[@"视频",@"热点",@"推荐"];
    segment.contentInset = UIEdgeInsetsMake(5, 10, 5, 10);
    [self.view addSubview:segment];
    [segment reloadData];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segment.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(segment.frame))];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * segment.titles.count, scrollView.frame.size.height);
    [self.view addSubview:scrollView];
    
    for (NSInteger i=0; i<segment.titles.count; i++) {
        UIViewController *vc1 = [[UIViewController alloc] init];
        vc1.view.frame = CGRectMake(i*scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
//        vc1.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.f green:arc4random()%255/255.f blue:arc4random()%255/255.f alpha:1];
        [scrollView addSubview:vc1.view];
        [self addChildViewController:vc1];
        
        UIButton *titleBtn = [[UIButton alloc] init];
        [titleBtn setTitle:segment.titles[i] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [titleBtn setFrame:CGRectMake(0, 0, 100, 100)];
        titleBtn.center = CGPointMake(vc1.view.frame.size.width/2.f, vc1.view.frame.size.height/2.f);
        [vc1.view addSubview:titleBtn];
    }
    
    segment.contentScrollView = scrollView;
}


@end
