//
//  BBNavigationController.m
//  BBNavgationController
//
//  Created by bobo on 2017/1/1.
//  Copyright © 2017年 bobo. All rights reserved.
//

static const float kDurationTime = 0.30;
static const float kScaleValue = 0.95;
static const float kCoverAphla = 0.2;

#import "BBNavigationController.h"

@interface BBNavigationController ()
{
    CGPoint startTouch; //拖动开始时位置
    BOOL isMoving;      //是否在拖动中
    UIImageView *lastScreenShotView;
}
@property (nonatomic,retain) NSMutableArray *screenShotsList;//存截
@property (nonatomic, strong) UIView *cover;

@end

@implementation BBNavigationController
#pragma mark - lazy method

- (UIView *)cover
{
    if (!_cover) {
        
        UIView *cover = [[UIView alloc] init];
        cover.backgroundColor = [UIColor blackColor];
        
        cover.frame = [UIApplication sharedApplication].keyWindow.bounds;
        cover.alpha = kCoverAphla;
        self.cover = cover;
    }
    return _cover;
}

- (NSMutableArray *)screenShotsList
{
    if (!_screenShotsList) {
        _screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
    }
    return _screenShotsList;
}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:panGesture];
    
    isMoving = NO;
    
}

#pragma mark - 重写push
/**
 *  重写push，是为了截张图片。还有重写navgationItem按钮并监听
 */

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        /* 设置导航栏上面的内容 */
        // 设置左边的返回按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        [btn setImage:[UIImage imageNamed:@"nav_return"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    } else {
        
    }
    
    [self.screenShotsList addObject:[self ViewRenderImage]];
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - 重写pop方法

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    
    UIViewController *popVC = nil;
    
    if (animated) {
        
        if (self.childViewControllers.count > 0) {
            
            [self addScreenShotIsTheFirst:NO];
        }
        
        //先缩放图片 kScaleValue
        lastScreenShotView.transform = CGAffineTransformMakeScale(kScaleValue, kScaleValue);
        
        [UIView animateWithDuration:kDurationTime animations:^{
            
            [self moveViewWithX:[UIScreen mainScreen].bounds.size.width];
            self.cover.alpha = 0;
        } completion:^(BOOL finished) {
            
            [super popViewControllerAnimated:NO];
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            self.cover.alpha = kCoverAphla;
            [self.screenShotsList removeLastObject];
            if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
            
        }];
        
        popVC = [self.viewControllers lastObject];
        
    }else{
        
        popVC = [super popViewControllerAnimated:NO];
        
    }
    return popVC;
}
#pragma mark - 重写popToRoot
- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    
    if (self.childViewControllers.count > 0) {
        
        [self addScreenShotIsTheFirst:YES];
    }
    
    //先缩放图片 kScaleValue
    lastScreenShotView.transform = CGAffineTransformMakeScale(kScaleValue, kScaleValue);
    
    [UIView animateWithDuration:kDurationTime animations:^{
        
        [self moveViewWithX:[UIScreen mainScreen].bounds.size.width];
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        
        [super popToRootViewControllerAnimated:NO];
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        self.view.frame = frame;
        self.cover.alpha = kCoverAphla;
        [self.screenShotsList removeAllObjects];
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
    }];
    return self.childViewControllers;
}

#pragma mark - 手势处理

- (void)handlePanGesture:(UIGestureRecognizer*)sender
{
    //顶级 controller 则不执行返回
    if(self.viewControllers.count <= 1){
        
        return;
        
    } else {
        
        //得到触摸中在window上拖动的过程中的xy坐标
        CGPoint translation = [sender locationInView:[UIApplication sharedApplication].keyWindow];
        
        if (translation.x - startTouch.x < 0) {//禁止向左移动
            isMoving = NO;
        }
        
        if(sender.state == UIGestureRecognizerStateEnded){
            isMoving = NO;
            
            //如果结束坐标大于开始坐标100像素就动画效果移动
            if (translation.x - startTouch.x > 100) {
                [UIView animateWithDuration:kDurationTime animations:^{
                    
                    [self moveViewWithX:[UIScreen mainScreen].bounds.size.width];
                    self.cover.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    
                    [self gesturePopViewControllerAnimated:NO];
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                    self.cover.alpha = kCoverAphla;
                    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
                    
                }];
                
            }else{
                
                [UIView animateWithDuration:kDurationTime animations:^{
                    [self moveViewWithX:0];
                }];
            }
        }else if(sender.state == UIGestureRecognizerStateBegan){
            
            startTouch = translation;
            isMoving = YES;
            [self addScreenShotIsTheFirst:NO];
        }
        
        if (isMoving) {
            [self moveViewWithX:translation.x - startTouch.x];
        }
        
    }
    
}

#pragma mark - 私有方法

/**
 *  截图
 */
- (UIImage *)ViewRenderImage
{
    //这里如果传window的size会报错,因为程序刚启动的时候界面是push进来的，此时window还没有值，
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), YES, 0.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)back
{
    // 因为self本来就是一个导航控制器，self.navigationController这里是nil的
    [self popViewControllerAnimated:YES];
}

/**
 *  添加背景图片到window上
 */
- (void)addScreenShotIsTheFirst:(BOOL)whether
{
    UIImage *screenShot;
    if (whether == YES) {
        screenShot = [self.screenShotsList firstObject];
    } else {
        screenShot = [self.screenShotsList lastObject];
    }
    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
    lastScreenShotView = [[UIImageView alloc] initWithImage:screenShot];
    [[UIApplication sharedApplication].keyWindow insertSubview:lastScreenShotView atIndex:0];
    [[UIApplication sharedApplication].keyWindow insertSubview:self.cover aboveSubview:lastScreenShotView];
}

- (UIViewController *)gesturePopViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    return [self popViewControllerAnimated:animated];
}

- (void)moveViewWithX:(float)x
{
    x = x > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.width : x;
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    float scale;
    if (kScaleValue == 1) {
        scale = kScaleValue;//缩放大小
    } else {
        scale = (x / 6400) + kScaleValue;//缩放大小
    }
    
    if (x == [UIScreen mainScreen].bounds.size.width) {
        
        lastScreenShotView.transform = CGAffineTransformIdentity;
        
    }else{
        //缩放scale
        lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
