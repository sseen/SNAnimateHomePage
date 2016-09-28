//
//  ContainerViewController.m
//  ContainerVC
//
//  Created by sseen on 2016/8/31.
//  Copyright © 2016年 sseen. All rights reserved.
//

#import "ContainerViewController.h"

//自定义nslog 发布时不打印日志
#ifdef DEBUG
//#define DebugLog(format,...) NSLog(format,##__VA_ARGS__)
#define NSLog(format, ...)  do {                                                                                \
fprintf(stderr, "\n<%s : %d> %s\n",                                         \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
} while (0)
#else
//#define DebugLog(format,...)
#define NSLog(FORMAT, ...) nil
#endif


static const CGFloat kNonModalViewMinScale = 0.9;
static const CGFloat kNonModalViewMinAlpha = 0.6;

@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.

@end

@interface PrivateAnimatedTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@end

@interface ContainerViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *privateContainerView; /// The view hosting the child view controllers views.
@property (nonatomic, strong) UIView *privateButtonsView;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizerPan ;

@property (nonatomic, strong) PrivateAnimatedTransition *animator;
@property (nonatomic, strong) PrivateTransitionContext  *transitionContext;
@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *rootView = self.view;
    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor orangeColor];
    self.privateContainerView.opaque = YES;
    
    self.privateButtonsView = [[UIView alloc] init];
    self.privateButtonsView.backgroundColor = [UIColor clearColor];
    self.privateButtonsView.tintColor = [UIColor colorWithWhite:1 alpha:0.75f];
    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.privateButtonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rootView addSubview:self.privateContainerView];
    
    // Container view fills out entire root view.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    
    self.upVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"upVC"];
    self.downVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"downVC"];
    [_upVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_downVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:_upVC];
    [self addChildViewController:_downVC];
    
    UIView *desView = _upVC.view;
    //desView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.privateContainerView addSubview:desView];
    
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.upVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.upVC.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.upVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.upVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [_upVC didMoveToParentViewController:self];
    
    desView = _downVC.view;
    //desView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.privateContainerView addSubview:desView];
    
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.downVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.downVC.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.downVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_privateContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.downVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upVC.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [_downVC didMoveToParentViewController:self];
    
    [rootView addSubview:self.privateButtonsView];
    
    // Place buttons view in the top half, horizontally centered.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.downVC.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.downVC.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_privateContainerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    self.gestureRecognizerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
    [self.privateButtonsView addGestureRecognizer:_gestureRecognizerPan];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)userDidPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
    
    // Note: Only one presentation may occur at a time, as per usual
    self.animator = [[PrivateAnimatedTransition alloc] init];
    _animator.interactive = true;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self _transitionToChildViewController:self.downVC animatro:_animator context:nil velocityY:velocity.y];

        
        
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
        CGFloat ratio = location.y / CGRectGetHeight(self.parentViewController.view.bounds);
        NSLog(@"UIGestureRecognizerStateChanged - %@", NSStringFromCGPoint(location));
        NSLog(@"UIGestureRecognizerStateChanged - %f", ratio);
        self.animator.transitionContext = self.transitionContext;
        [self.animator updateInteractiveTransition:ratio];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
        
        CGFloat velocityY = [recognizer velocityInView:self.view].y;
        NSLog(@"ss %f",velocityY);
        self.animator.transitionContext = self.transitionContext;
        if (velocityY < 0) {
            [self.animator finishInteractiveTransition];
        } else {
//            self.upVC = nil;
//            self.upVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"upVC"];
//            [self addChildViewController:self.upVC];
//            [self.privateContainerView addSubview:self.upVC.view];
//            [self.upVC didMoveToParentViewController:self];
            [self.animator cancelInteractiveTransition];
        }
    } else {
        CGFloat velocityY = [recognizer velocityInView:self.view].y;
        NSLog(@"ss %f",velocityY);
        self.animator.transitionContext = self.transitionContext;
        if (velocityY < 0) {
            [self.animator finishInteractiveTransition];
        } else {
            //            self.upVC = nil;
            //            self.upVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"upVC"];
            //            [self addChildViewController:self.upVC];
            //            [self.privateContainerView addSubview:self.upVC.view];
            //            [self.upVC didMoveToParentViewController:self];
            [self.animator cancelInteractiveTransition];
        }
    }
}

#pragma mark - private
- (void)_transitionToChildViewController:(UIViewController *)toViewController animatro:(PrivateAnimatedTransition *)animator2 context:(PrivateTransitionContext *)context2 velocityY:(CGFloat)velocityY{
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    PrivateTransitionContext *transitionContext = nil;
    
    animator = (animator2 ? animator2: [[PrivateAnimatedTransition alloc] init]);
    
    
    
    if (velocityY < 0) {
        
    
//        UIView *toView = toViewController.view;
//        [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
//        toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        // toView.frame = self.privateContainerView.bounds;
//        
//        [fromViewController willMoveToParentViewController:nil];
//        [self addChildViewController:toViewController];
//        
//        // If this is the initial presentation, add the new child with no animation.
//        if (!fromViewController) {
//            [self.privateContainerView addSubview:toViewController.view];
//            [toViewController didMoveToParentViewController:self];
//            return;
//        }
        
        // Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.
        
        transitionContext = (context2? context2: [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight: true ]);
        self.transitionContext = transitionContext;
        self.animator.transitionContext = transitionContext;
        
        transitionContext.animated = YES;
        transitionContext.interactive = NO;
        transitionContext.completionBlock = ^(BOOL didComplete) {
//            [fromViewController.view removeFromSuperview];
//            [fromViewController removeFromParentViewController];
//            [toViewController didMoveToParentViewController:self];
            
            if ([animator respondsToSelector:@selector (animationEnded:)]) {
                [animator animationEnded:didComplete];
            }
        };
        
    } else {
        
        transitionContext = (context2? context2: [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight: true ]);
        self.transitionContext = transitionContext;
        self.animator.transitionContext = transitionContext;
        
        transitionContext.animated = YES;
        transitionContext.interactive = NO;
        transitionContext.completionBlock = ^(BOOL didComplete) {
            
            if ([animator respondsToSelector:@selector (animationEnded:)]) {
                [animator animationEnded:didComplete];
            }
        };
        
    }
    
    
    [animator animateTransition:transitionContext];
}

- (IBAction)unwindSegueToRedViewController:(UIStoryboardSegue *)segue {
    [self userDidPan:nil];
}

@end

#pragma mark - Private Transitioning Classes

@interface PrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };
        
        
        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}
- (UIView *)viewForKey:(NSString *)key {
    return [(UIViewController *)self.privateViewControllers[key] view];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)


@end

@implementation PrivateAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    if (true) {
//        // [self startInteractiveTransition:transitionContext];
//    } else {
//        
//    
//    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//    // When sliding the views horizontally in and out, figure out whether we are going left or right.
//    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
//    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
//    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
//    
//    [[transitionContext containerView] addSubview:toViewController.view];
//    toViewController.view.alpha = 0;
//    toViewController.view.transform = CGAffineTransformInvert (travel);
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
//        fromViewController.view.transform = travel;
//        fromViewController.view.alpha = 0;
//        toViewController.view.transform = CGAffineTransformIdentity;
//        toViewController.view.alpha = 1;
//    } completion:^(BOOL finished) {
//        fromViewController.view.transform = CGAffineTransformIdentity;
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
//        
//    }
}


#pragma mark - UIViewControllerInteractiveTransitioning Methods

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        // The order of these matters – determines the view hierarchy order.
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        endFrame.origin.x -= CGRectGetHeight([[transitionContext containerView] bounds]);
    }
    else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }
    
    toViewController.view.frame = endFrame;
    
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [(UINavigationController *)toViewController navigationBar].alpha = 0;
    
    // Presenting goes from 0...1 and dismissing goes from 1...0
    CGRect frame = CGRectOffset([[transitionContext containerView] bounds], 0, CGRectGetHeight([[transitionContext containerView] bounds]) * percentComplete);
    NSLog(@"++++%@", [transitionContext containerView]);
    NSLog(@"%@", NSStringFromCGRect(frame));
    NSLog(@"%f", percentComplete);
    

        toViewController.view.frame = frame;
        // fromViewController.view.frame = frame;
        NSLog(@"%@ ----", NSStringFromCGRect(frame));
        
        float scaleFactor = kNonModalViewMinScale + (1 - kNonModalViewMinScale) * percentComplete;
        float alphaVal = kNonModalViewMinAlpha + (1 - kNonModalViewMinAlpha) * percentComplete;
        [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
        [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.alpha = alphaVal;
  
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    

        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], 0, 0);
        
        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = endFrame;
            toViewController.view.frame = endFrame;
            [(UINavigationController *)toViewController navigationBar].alpha = 1.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
//            [[[UIApplication sharedApplication] keyWindow] addSubview:toViewController.view];
        }];

    
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGAffineTransform transformVal = CGAffineTransformIdentity;
    
    NSLog(@"%@", NSStringFromCGRect(fromViewController.view.frame));
    NSLog(@"%@", NSStringFromCGRect(toViewController.view.frame));

    
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = CGRectMake(0, 0, 375, 388);
            fromViewController.view.transform = transformVal;
            fromViewController.view.alpha = 1;
            
            toViewController.view.frame = CGRectMake(0, 388, 375, 388);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    
}



@end
