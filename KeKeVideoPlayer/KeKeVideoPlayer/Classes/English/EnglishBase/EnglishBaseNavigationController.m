//
//  EnglishBaseNavigationController.m
//  English
//
//  Created by edward lannister on 2024/03/01.
//  Copyright © 2024 KeKeStudio. All rights reserved.
//

#import "EnglishBaseNavigationController.h"

@interface EnglishBaseNavigationController ()

@end

@implementation EnglishBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    [titleTextAttributes setObject:[UIFont boldSystemFontOfSize:18] forKey:NSFontAttributeName];
    [titleTextAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [self.navigationBar setTitleTextAttributes:titleTextAttributes];
}

@end
