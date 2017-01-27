//
//  PhotoViewController.m
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/26/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import "PhotoViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PhotoViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMovieImageTap:)];
  
  // UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
  
  tapGestureRecognizer.delegate = self;
  // pinchGestureRecognizer.delegate = self;
  self.photoScrollView.delegate = self;
  
  [self.photoImageView addGestureRecognizer:tapGestureRecognizer];
  // [self.photoImageView addGestureRecognizer:pinchGestureRecognizer];
  self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
  
  self.photoImageView.userInteractionEnabled = YES;
  [self.photoImageView setImageWithURL:self.photoURL];
  self.navigationController.navigationBar.hidden = YES;
  self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

#pragma mark - Actions
- (void) onMovieImageTap:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void) didPinch: (UIPinchGestureRecognizer *) sender {
//  NSLog(@"Pinch: %f", sender.scale);
//  CGFloat scale = sender.scale;
//  self.photoImageView.transform = CGAffineTransformScale( self.photoImageView.transform , scale, scale);
//  sender.scale = 1;
//}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.photoImageView;
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
