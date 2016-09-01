//
//  ContainerViewController.m
//  ContainerVC
//
//  Created by sseen on 2016/8/31.
//  Copyright © 2016年 sseen. All rights reserved.
//

#import "ContainerViewController.h"

@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end

@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface ContainerViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *privateContainerView; /// The view hosting the child view controllers views.
@property (nonatomic, strong) UIView *privateButtonsView;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizerPan ;
@property (nonatomic, strong) UIViewController *upVC;
@property (nonatomic, strong) UIViewController *downVC;
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
    self.privateButtonsView.backgroundColor = [UIColor purpleColor];
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
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [self _transitionToChildViewController:self.downVC];
//        self.interactive = YES;
//        self.presenting = YES;
//        TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithPanTarget:self];
//        viewController.modalPresentationStyle = UIModalPresentationCustom;
//        viewController.transitioningDelegate = self;
//        [self.parentViewController presentViewController:viewController animated:YES completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
        CGFloat ratio = location.y / CGRectGetHeight(self.parentViewController.view.bounds);
        NSLog(@"UIGestureRecognizerStateChanged - %@", NSStringFromCGPoint(location));
        NSLog(@"UIGestureRecognizerStateChanged - %f", ratio);
        
        // [self updateInteractiveTransition:ratio];
        
        
        //        CGFloat percentage = [recognizer translationInView:_parentViewController.view].y / CGRectGetHeight(_parentViewController.view.bounds);
        //        NSLog(@"%f-------", [recognizer velocityInView:recognizer.view.superview].y);
        //        NSLog(@"%f", percentage);
        //        NSLog(@"%@", recognizer.view);
        //        NSLog(@"%@", NSStringFromCGPoint([recognizer translationInView:_parentViewController.view]));
        //        NSLog(@"%@", [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view);
        //
        //        float scaleFactor = kNonModalViewMinScale + (1 - kNonModalViewMinScale) * percentage;
        //        float alphaVal = kNonModalViewMinAlpha + (1 - kNonModalViewMinAlpha) * percentage;
        //
        //        [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleFactor, scaleFactor);
        //        [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.alpha = alphaVal;
        //
        //        CGRect modalVCFrame = [_transitionContext viewForKey:UITransitionContextToViewKey].frame;
        //        modalVCFrame.origin.y = percentage * CGRectGetHeight(_parentViewController.view.frame) + kModalViewYOffset;
        //        [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.frame = modalVCFrame;
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
        
        CGFloat velocityY = [recognizer velocityInView:recognizer.view.superview].y;
        
        
//        BOOL cancelUp = (velocityY > 0) || (velocityY == 0 && recognizer.view.frame.origin.y < CGRectGetHeight(_parentViewController.view.bounds)/2);
//        
//        CGFloat points = cancelUp ? recognizer.view.frame.origin.y : CGRectGetHeight(_parentViewController.view.bounds) - recognizer.view.frame.origin.y;
//        NSTimeInterval duration = points / velocityY;
        
//        if (duration < 0.2) {
//            duration = 0.2;
//        }
//        else if(duration > 0.4){
//            duration = 0.4;
//        }
//        
//        if (self.presenting) {
//            if (velocity.y < 0) {
//                [self finishInteractiveTransition];
//            }
//            else {
//                [self cancelInteractiveTransition];
//            }
//        }
//        else {
//            if (velocity.y > 0) {
//                [self finishInteractiveTransition];
//            }
//            else {
//                [self cancelInteractiveTransition];
//            }
//        }
    }
}

#pragma mark - private
- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController) {
        [self.privateContainerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }
    
    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
//    if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
//        animator = [self.delegate containerViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
//    }
    animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);
    
    // Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.

    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight: true ];
    
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
    };
    
    [animator animateTransition:transitionContext];
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

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

@implementation PrivateAnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // When sliding the views horizontally in and out, figure out whether we are going left or right.
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = travel;
        fromViewController.view.alpha = 0;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
