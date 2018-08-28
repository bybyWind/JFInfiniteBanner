//
//  JFInfiniteBanner.m
//  JFInfiniteBanner
//
//  Created by 社会人 on 2018/8/28.
//  Copyright © 2018年 社会人. All rights reserved.
//

#import "JFInfiniteBanner.h"

#define kImageViewRadius 12
#define kSCROLLVIEWX (24)
#define kshadowOpacity (0.6)
#define kBANNERWIDTH (self.bounds.size.width-2*kSCROLLVIEWX) //广告的宽度
#define kBANNERHEIGHT  (self.bounds.size.height-10-8-12)//广告的高度
#define kSCALESPACE (0.1) //放大缩小的长度比例

static CGFloat const chageImageTime = 3.0; //滚动间隔
static NSInteger currentImage = 1;//记录中间图片的下标,开始总是为1
@interface JFInfiniteBanner()<UIScrollViewDelegate>{
    BOOL _isTimeUp; //NO表示，手动滑动，要停止计时器。YES表示自动滑动，开启计时器。
    NSTimer *_moveTime;
    CGFloat _lastContentOffX;//上一次滑动的contentOff.x
    NSInteger _whitchMiddle;//标记第几个ImageView在中间
}
@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,strong)UIScrollView *bgScrollView;
@property(nonatomic,strong)NSMutableArray *imageViewArray;
@property(nonatomic,strong)UIImageView *leftImageView;
@property(nonatomic,strong)UIImageView *centerImageView;
@property(nonatomic,strong)UIImageView *rightImgaeView;
@property(nonatomic,strong)UIImageView *beforeLeftImageView;
@property(nonatomic,strong)UIImageView *afterRightImageView;

@end
@implementation JFInfiniteBanner

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        _lastContentOffX = kBANNERWIDTH*2;
        _whitchMiddle = 2;
        self.backgroundColor = [UIColor whiteColor];
        [self imageViewArray];
        [self bgScrollView];
        
    }
    return self;
}




#pragma mark - scrollViewDelegate
/**
 开始拉
 
 @param scrollView <#scrollView description#>
 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isTimeUp = NO;
    [self cancelTimer];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_lastContentOffX<scrollView.contentOffset.x) {
        //右滑
        UIImageView *centerView = self.imageViewArray[_whitchMiddle];
        UIImageView *leftView = self.imageViewArray[_whitchMiddle-1];
        UIImageView *rightView = self.imageViewArray[_whitchMiddle+1];
        CGRect centerViewFrame = [self convertRect:centerView.frame fromView:centerView.superview];
        CGRect leftViewFrame = [self convertRect:leftView.frame fromView:leftView.superview];
        CGRect rightViewFrame = [self convertRect:rightView.frame fromView:rightView.superview];
        CGFloat centerViewMiddleX =  centerViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat leftViewMiddleX =  leftViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat rightViewMiddleX =  rightViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat centerDistance = fabs(centerViewMiddleX-self.bounds.size.width/2);//中线
        CGFloat leftDistance = fabs(leftViewMiddleX-self.bounds.size.width/2);//中线
        CGFloat rightDistance = fabs(rightViewMiddleX-self.bounds.size.width/2);//中线
        [self adjustImageViewScale:centerView WithScale:centerDistance/kBANNERWIDTH];
        [self adjustImageViewScale:leftView WithScale:leftDistance/kBANNERWIDTH];
        [self adjustImageViewScale:rightView WithScale:rightDistance/kBANNERWIDTH];
    }
    if (_lastContentOffX>scrollView.contentOffset.x) {
        //左滑
        UIImageView *centerView = self.imageViewArray[_whitchMiddle];
        UIImageView *leftView = self.imageViewArray[_whitchMiddle-1];
        UIImageView *rightView = self.imageViewArray[_whitchMiddle+1];
        
        CGRect centerViewFrame = [self convertRect:centerView.frame fromView:centerView.superview];
        CGRect leftViewFrame = [self convertRect:leftView.frame fromView:leftView.superview];
        CGRect rightViewFrame = [self convertRect:rightView.frame fromView:rightView.superview];
        CGFloat centerViewMiddleX =  centerViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat leftViewMiddleX =  leftViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat rightViewMiddleX =  rightViewFrame.origin.x+kBANNERWIDTH/2;
        CGFloat centerDistance = fabs(centerViewMiddleX-self.bounds.size.width/2);//中线
        CGFloat leftDistance = fabs(leftViewMiddleX-self.bounds.size.width/2);//中线
        CGFloat rightDistance = fabs(rightViewMiddleX-self.bounds.size.width/2);//中线
        [self adjustImageViewScale:centerView WithScale:centerDistance/kBANNERWIDTH];
        [self adjustImageViewScale:leftView WithScale:leftDistance/kBANNERWIDTH];
        [self adjustImageViewScale:rightView WithScale:rightDistance/kBANNERWIDTH];
    }
    _lastContentOffX = scrollView.contentOffset.x;
    
    
    if (scrollView.contentOffset.x>kBANNERWIDTH*3) {
        scrollView.scrollEnabled = NO;
        [self didManualScrollAdjustView];
    }
    if (scrollView.contentOffset.x<kBANNERWIDTH) {
        scrollView.scrollEnabled = NO;
        [self didManualScrollAdjustView];
    }
}
/**
 scrollView结束加速
 
 @param scrollView <#scrollView description#>
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self didManualScrollAdjustView];
}

/**
 scrollView结束拉动
 */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0){
    [self didManualScrollAdjustView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //自动滑动动画后 进行自动滑动的界面设置。在automaticScroll方法之后会执行。
    if (_isTimeUp) {
        [self didAutoScrollAdjustView];
    }
}
#pragma mark - private
/**
 自动滚动
 */
- (void)automaticScroll
{
    [self.bgScrollView setContentOffset:CGPointMake(kBANNERWIDTH * 3, 0) animated:YES];
    _isTimeUp = YES;
    //    //自动滚动的时候。第三个自然是中间的啦。
    //    _whitchMiddle = 2;
}
/**
 自动滑动后调整视图
 */
-(void)didAutoScrollAdjustView{
    
    if (self.imageGroup.count == 0) {
    }else if (self.imageGroup.count == 1){
    }else{
        
        currentImage = (currentImage+1)%self.imageGroup.count;
        self.pageControl.currentPage = (self.pageControl.currentPage + 1)%self.imageGroup.count;
        
        
        
        self.beforeLeftImageView.image = self.imageGroup[(currentImage-2+self.imageGroup.count)%self.imageGroup.count];
        
        self.leftImageView.image = self.imageGroup[(currentImage-1+self.imageGroup.count)%self.imageGroup.count];
        
        self.centerImageView.image =self.imageGroup[currentImage%self.imageGroup.count];
        
        self.rightImgaeView.image = self.imageGroup[(currentImage+1)%self.imageGroup.count];
        
        self.afterRightImageView.image = self.imageGroup[(currentImage+2)%self.imageGroup.count];
        
        self.bgScrollView.contentOffset = CGPointMake(kBANNERWIDTH*2, 0);
        
        //添加圆角
        [self  addRoundedCorners:self.beforeLeftImageView];
        [self  addRoundedCorners:self.leftImageView];
        [self  addRoundedCorners:self.centerImageView];
        [self  addRoundedCorners:self.rightImgaeView];
        [self  addRoundedCorners:self.afterRightImageView];
        
        //自动滑动结束后要缩放大小。
        [self amplification:self.centerImageView];
        UIImageView *rightImageView = self.imageViewArray[3];
        [self narrowImageView:rightImageView];
        
    }
}

/**
 手动滑动后，修改图片的位置。
 */
-(void)didManualScrollAdjustView{
    self.bgScrollView.scrollEnabled = YES;
    if (self.imageGroup.count == 0) {
    }else if (self.imageGroup.count == 1){
    }else{
        //手动控制图片滚动应该取消那个三秒的计时器
        [self setupTimer];
        _isTimeUp = YES;
        
        if (self.bgScrollView.contentOffset.x == kBANNERWIDTH)
        {
            currentImage = (currentImage-1+self.imageGroup.count)%self.imageGroup.count;
            //当往左滑动的时候，可能出现负数取模的情况，如果小于0就加imageGroup.count
            self.pageControl.currentPage =  ((self.pageControl.currentPage+self.imageGroup.count- 1)%self.imageGroup.count);
        }
        else if(self.bgScrollView.contentOffset.x == kBANNERWIDTH * 3)
        {
            currentImage = (currentImage+1)%self.imageGroup.count;
            self.pageControl.currentPage = (self.pageControl.currentPage + 1)%self.imageGroup.count;
        }
        else
        {
            return;
        }
        self.beforeLeftImageView.image = self.imageGroup[(currentImage-2+self.imageGroup.count)%self.imageGroup.count];
        self.leftImageView.image = self.imageGroup[(currentImage-1+self.imageGroup.count)%self.imageGroup.count];
        self.centerImageView.image =self.imageGroup[currentImage%self.imageGroup.count];
        self.rightImgaeView.image = self.imageGroup[(currentImage+1)%self.imageGroup.count];
        self.afterRightImageView.image = self.imageGroup[(currentImage+2)%self.imageGroup.count];
   
        
        
        self.bgScrollView.contentOffset = CGPointMake(kBANNERWIDTH*2, 0);
        
        //添加圆角
        [self  addRoundedCorners:self.beforeLeftImageView];
        [self  addRoundedCorners:self.leftImageView];
        [self  addRoundedCorners:self.centerImageView];
        [self  addRoundedCorners:self.rightImgaeView];
        [self  addRoundedCorners:self.afterRightImageView];
        
        //手动滑动结束后要缩放大小。
        [self amplification:self.centerImageView];
        UIImageView *leftImageView = self.imageViewArray[1];
        [self narrowImageView:leftImageView];
        UIImageView *rightImageView = self.imageViewArray[3];
        [self narrowImageView:rightImageView];
    }
}

/**
 设置定时器
 */
- (void)setupTimer
{
    if (!_moveTime) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:chageImageTime target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
        _moveTime = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}
/**
 取消定时器
 */
-(void)cancelTimer{
    [_moveTime invalidate];
    _moveTime = nil;
}

/**
 直接设置为缩小视图的坐标
 
 @param imageView <#imageView description#>
 */
-(void)narrowImageView:(UIImageView *)imageView{
    imageView.frame = CGRectMake(kBANNERWIDTH*kSCALESPACE/2, kBANNERHEIGHT*kSCALESPACE/2, kBANNERWIDTH*(1-kSCALESPACE), kBANNERHEIGHT*(1-kSCALESPACE));
    imageView.layer.shadowOpacity = 0.0;
}
/**
 直接设置为放大视图的坐标
 
 @param imageView <#imageView description#>
 */
-(void)amplification:(UIImageView *)imageView{
    
    imageView.frame = CGRectMake(0, 0, kBANNERWIDTH, kBANNERHEIGHT);
    imageView.layer.shadowOpacity = kshadowOpacity;
}
/**
 通过缩率比例来缩小放大视图的坐标
 
 @param scale 为 (imageView的middle距离屏幕中间的距离)/bannerwidth
 */
-(void)adjustImageViewScale:(UIImageView *)imageView WithScale:(CGFloat)scale{
    if (scale>1) {
        return;
    }
    imageView.frame = CGRectMake(kBANNERWIDTH*kSCALESPACE*scale/2, kBANNERHEIGHT*kSCALESPACE*scale/2, kBANNERWIDTH*((1-kSCALESPACE)+kSCALESPACE*(1-scale)), kBANNERHEIGHT*((1-kSCALESPACE)+kSCALESPACE*(1-scale)));
    imageView.layer.shadowOpacity = kshadowOpacity*(1-scale);
}

/**
 imageView加圆角
 */
-(void)addRoundedCorners:(UIImageView *)imageView{
    imageView.image = [self imageWithImage:imageView.image CornerRadius:kImageViewRadius];
}
- (UIImage *)imageWithImage:(UIImage *)image CornerRadius:(CGFloat)radius {
    CGRect rect = (CGRect){0.f, 0.f, image.size};
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [image drawInRect:rect];
    UIImage *editImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return editImage;
}

#pragma mark - event
-(void)centerImagViewClick{
    if ([self.delegate respondsToSelector:@selector(JFInfiniteBannerDidSelectedAtIndex:)]) {
        [self.delegate JFInfiniteBannerDidSelectedAtIndex:currentImage];
    }
}

#pragma mark - setter
-(void)setImageGroup:(NSArray *)imageGroup{
    //    imageGroup = @[@"http://3g.168p2p.com/data/upfiles/images/2018-08/09/1000553_scrollpic_new_1533815563360.jpg",@"http://3g.168p2p.com/data/upfiles/images/2018-08/07/1000950_scrollpic_new_1533628992228.jpg"];
    _imageGroup = imageGroup;
    self.pageControl.numberOfPages = imageGroup.count;
    if (_imageGroup.count == 0) {
    }else if (_imageGroup.count == 1){
        currentImage = 0;
        self.bgScrollView.scrollEnabled = NO;
        self.centerImageView.image = imageGroup[0];
      
        [self  addRoundedCorners:self.centerImageView];//添加圆角
    }else{
        [self setupTimer];
        currentImage = 1;
        self.bgScrollView.contentOffset = CGPointMake(kBANNERWIDTH*2, 0);
        
      
        self.beforeLeftImageView.image = self.imageGroup[(currentImage-2+self.imageGroup.count)%self.imageGroup.count];
        self.leftImageView.image = self.imageGroup[(currentImage-1+self.imageGroup.count)%self.imageGroup.count];
        self.centerImageView.image =self.imageGroup[currentImage%self.imageGroup.count];
        self.rightImgaeView.image = self.imageGroup[(currentImage+1)%self.imageGroup.count];
        self.afterRightImageView.image = self.imageGroup[(currentImage+2)%self.imageGroup.count];
        
       
        
        //添加圆角
        [self  addRoundedCorners:self.beforeLeftImageView];
        [self  addRoundedCorners:self.leftImageView];
        [self  addRoundedCorners:self.centerImageView];
        [self  addRoundedCorners:self.rightImgaeView];
        [self  addRoundedCorners:self.afterRightImageView];
        
        
    }
}



#pragma mark - getter
-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-10, self.bounds.size.width, 10)];
        [self addSubview:_pageControl];
        //添加委托方法，当点击小白点就执行此方法
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];// 设置非选中页的圆点颜色
        _pageControl.currentPageIndicatorTintColor = [UIColor blueColor]; // 设置选中页的圆点颜色
    }
    return _pageControl;
}
-(UIScrollView *)bgScrollView{
    if (!_bgScrollView ){
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kSCROLLVIEWX, 8, kBANNERWIDTH, kBANNERHEIGHT)];
        _bgScrollView.pagingEnabled = YES;
        _bgScrollView.bounces = NO;
        //剪裁效果设为NO,使不满屏的UIScrollView显示出满屏的效果
        _bgScrollView.clipsToBounds  = NO;
        _bgScrollView.delegate = self;
        _bgScrollView.contentSize = CGSizeMake(kBANNERWIDTH*5, 0);
        _bgScrollView.contentOffset = CGPointMake(kBANNERWIDTH*2, 0);
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        [self.pageControl layoutIfNeeded];
        [self addSubview:_bgScrollView];
        
    }
    return _bgScrollView;
}
-(UIImageView *)beforeLeftImageView
{
    if (!_beforeLeftImageView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [self.bgScrollView addSubview:bgView];
        _beforeLeftImageView = [[UIImageView alloc]init];
        [self narrowImageView:_beforeLeftImageView];
        [bgView addSubview:_beforeLeftImageView];
        
        //加阴影
        _beforeLeftImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _beforeLeftImageView.layer.shadowOffset = CGSizeMake(0, 3.0);
        _beforeLeftImageView.layer.shadowOpacity = 0.0;
    }
    return _beforeLeftImageView;
}
-(UIImageView *)leftImageView
{
    if (!_leftImageView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kBANNERWIDTH, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [self.bgScrollView addSubview:bgView];
        _leftImageView = [[UIImageView alloc]init];
        [self narrowImageView:_leftImageView];
        [bgView addSubview:_leftImageView];
        
        //加阴影
        _leftImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _leftImageView.layer.shadowOffset = CGSizeMake(0, 3.0);
        _leftImageView.layer.shadowOpacity = 0.0;
    }
    return _leftImageView;
}

-(UIImageView *)centerImageView
{
    if (!_centerImageView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kBANNERWIDTH*2, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [self.bgScrollView addSubview:bgView];
        _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [bgView addSubview:_centerImageView];
        
        //加阴影
        _centerImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _centerImageView.layer.shadowOffset = CGSizeMake(0, 3.0);
        _centerImageView.layer.shadowOpacity = kshadowOpacity;
        
        _centerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerImagViewClick)];
        [_centerImageView addGestureRecognizer:tap];
        
        
    }
    return _centerImageView;
}
-(UIImageView *)rightImgaeView
{
    if (!_rightImgaeView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kBANNERWIDTH*3, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [self.bgScrollView addSubview:bgView];
        _rightImgaeView = [[UIImageView alloc]init];
        [self narrowImageView:_rightImgaeView];
        
        [bgView addSubview:_rightImgaeView];
        //加阴影
        _rightImgaeView.layer.shadowColor = [UIColor grayColor].CGColor;
        _rightImgaeView.layer.shadowOffset = CGSizeMake(0, 3.0);
        _rightImgaeView.layer.shadowOpacity = 0.0;
    }
    return _rightImgaeView;
}

-(UIImageView *)afterRightImageView
{
    if (!_afterRightImageView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kBANNERWIDTH*4, 0, kBANNERWIDTH, kBANNERHEIGHT)];
        [self.bgScrollView addSubview:bgView];
        _afterRightImageView = [[UIImageView alloc]init];
        [self narrowImageView:_afterRightImageView];
        [bgView addSubview:_afterRightImageView];
        //加阴影
        _afterRightImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _afterRightImageView.layer.shadowOffset = CGSizeMake(0, 3.0);
        _afterRightImageView.layer.shadowOpacity = 0.0;
    }
    return _afterRightImageView;
}

-(NSMutableArray *)imageViewArray{
    if (!_imageViewArray) {
        _imageViewArray = [NSMutableArray array];
        [_imageViewArray addObject:self.beforeLeftImageView];
        [_imageViewArray addObject:self.leftImageView];
        [_imageViewArray addObject:self.centerImageView];
        [_imageViewArray addObject:self.rightImgaeView];
        [_imageViewArray addObject:self.afterRightImageView];
    }
    return _imageViewArray;
}


@end
