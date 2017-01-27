//
//  AppDelegate.m
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/23/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // Override point for customization after application launch.
//  UITabBarController *tabBarController = [[UITabBarController alloc] init];
//
//  MoviesTableViewController *nowPlayingMoviewController = [[MoviesTableViewController alloc] init];
//  nowPlayingMoviewController.tabBarItem.title = @"Now Playing";
//  //nowPlayingMoviewController.tabBarItem.image = [UIImage imageNamed:@"now_playing"];
//  
//  MoviesTableViewController *topRatedMoviesController = [[MoviesTableViewController alloc] init];
//  topRatedMoviesController.tabBarItem.title = @"Top Rated";
//  //topRatedMoviesController.tabBarItem.image = [UIImage imageNamed:@"star_empty"];
//  
//  NSArray *controllers = [NSArray arrayWithObjects:nowPlayingMoviewController, topRatedMoviesController, nil];
//  [tabBarController setViewControllers:controllers];
//  
//  self.window.rootViewController = tabBarController;
//  [self.window makeKeyAndVisible];
  
  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
