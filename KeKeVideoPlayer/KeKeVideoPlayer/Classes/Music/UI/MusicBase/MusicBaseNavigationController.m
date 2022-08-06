//
//  MusicBaseNavigationController.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicBaseNavigationController.h"

@interface MusicBaseNavigationController ()

@end

@implementation MusicBaseNavigationController

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
