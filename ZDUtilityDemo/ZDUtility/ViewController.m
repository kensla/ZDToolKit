//
//  ViewController.m
//  ZDUtility
//
//  Created by 符现超 on 15/7/11.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	NSArray *arr = @[@0, @1, @2];
	NSNumber *num = arr[4];
	NSLog(@"********%@", num);

	NSString *u = nil;
	//NSArray *a = [NSArray arrayWithObjects:@"h", u, nil];

	NSDictionary *dic = @{@"hello" : u};
	NSString *str = dic[@"hell"];
	NSLog(@"========== %@", str);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
