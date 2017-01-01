//
//  ViewController.m
//  BBNavgationController
//
//  Created by bobo on 2017/1/1.
//  Copyright © 2017年 bobo. All rights reserved.
//

#import "ViewController.h"

#import "ALSSecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    ALSSecondViewController *secondVc = [[ALSSecondViewController alloc] init];
    
    [self.navigationController pushViewController:secondVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
