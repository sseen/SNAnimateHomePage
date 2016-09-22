//
//  ViewController.m
//  ContainerVC
//
//  Created by sseen on 2016/8/31.
//  Copyright © 2016年 sseen. All rights reserved.
//

#import "ViewController.h"
#import "ContainerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ContainerViewController *controller =  [[segue.sourceViewController parentViewController] parentViewController];
    controller.downVC.view.hidden = true ;
    controller.upVC.view.frame = [UIScreen mainScreen].bounds;
}

@end
