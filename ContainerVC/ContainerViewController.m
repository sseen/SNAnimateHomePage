//
//  ContainerViewController.m
//  ContainerVC
//
//  Created by sseen on 2016/8/31.
//  Copyright © 2016年 sseen. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIViewController *upVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"upVC"];
    UIViewController *downVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"downVC"];
    [self addChildViewController:upVC];
    [self addChildViewController:downVC];
    
    UIView *desView = upVC.view;
    //desView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    desView.frame = CGRectMake(0, 0, self.view.frame.size.width, 368);
    [self.view addSubview:desView];
    [upVC didMoveToParentViewController:self];
    
    desView = downVC.view;
    //desView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    desView.frame = CGRectMake(0, 368, self.view.frame.size.width, 200);
    [self.view addSubview:desView];
    [downVC didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
