//
//  JFInfiniteBanner.h
//  JFInfiniteBanner
//
//  Created by 社会人 on 2018/8/28.
//  Copyright © 2018年 社会人. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol JFInfiniteBannerDelegate <NSObject>

- (void)JFInfiniteBannerDidSelectedAtIndex:(NSInteger)index;

@end
@interface JFInfiniteBanner : UIView

//数据源(UIImage)
@property (nonatomic, strong) NSArray *imageGroup;
//滚动控制接口
@property (nonatomic, weak) id<JFInfiniteBannerDelegate> delegate;

@end
