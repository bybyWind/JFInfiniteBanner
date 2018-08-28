//
//  ViewController.m
//  JFInfiniteBanner
//
//  Created by 社会人 on 2018/8/28.
//  Copyright © 2018年 社会人. All rights reserved.
//

#import "ViewController.h"
#import "JFInfiniteBanner.h"
@interface ViewController ()<JFInfiniteBannerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *imageArray = @[ [UIImage imageNamed:@"smile1.jpg"],
                             [UIImage imageNamed:@"smile2.jpg"],
                             [UIImage imageNamed:@"smile3.jpg"],
                             [UIImage imageNamed:@"smile4.jpg"],
                             [UIImage imageNamed:@"smile5.jpg"],
                           ];
    JFInfiniteBanner *banner = [[JFInfiniteBanner alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    banner.delegate = self;
    [self.view addSubview:banner];
    banner.imageGroup = imageArray;
}


- (void)JFInfiniteBannerDidSelectedAtIndex:(NSInteger)index{
    NSLog(@"%ld",index);
}

@end
