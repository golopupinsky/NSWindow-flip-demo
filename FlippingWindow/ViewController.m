//
//  ViewController.m
//  FlippingWindow
//
//  Created by Sergey Yuzepovich on 12.10.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (IBAction)flip:(id)sender {
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    [delegate flip];
}



@end
