//
//  BaseNavigationController.m
//  StreetDancing
//
//  Created by beartech on 15/4/14.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "BaseNavigationController.h"

@implementation BaseNavigationController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    [titleTextAttributes setObject:[UIFont boldSystemFontOfSize:18] forKey:NSFontAttributeName];
    [titleTextAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationBar setTitleTextAttributes:titleTextAttributes];
}

@end
