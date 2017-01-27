//
//  MovieDetailViewController.m
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/24/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "PhotoViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>


static float MOVIE_TOP_RATING = 350.0f;

@interface MovieDetailViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *detailContentView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UILabel *watchTrailerLabel;


- (void)fetchMovieById;
- (NSString *) getFormattedRating;
- (NSString *) getFormattedDuration;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.detailContentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  self.videoButton.hidden = YES;
  self.watchTrailerLabel.hidden = YES;
  
  [self fetchMovieById];
  // Do any additional setup after loading the view.
  [self updateMovieDetails];
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMovieImageTap:)];
  
  tapGestureRecognizer.delegate = self;
  
  [self.posterView addGestureRecognizer:tapGestureRecognizer];
  [self.detailScrollView addGestureRecognizer:tapGestureRecognizer];
  
  self.posterView.userInteractionEnabled = YES;
  self.detailScrollView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  BOOL shouldReceiveTouch = YES;
  // Do not enter full screen mode if tapped on detail view
  shouldReceiveTouch = (touch.view != self.detailContentView);
  return shouldReceiveTouch;
}

#pragma mark - Actions
- (IBAction)onVideoIconTap:(id)sender {

  if (self.movie.videoId) {
    XCDYouTubeVideoPlayerViewController *videoPlayerController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.movie.videoId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerController.moviePlayer];
    [self.navigationController presentViewController:videoPlayerController animated:YES completion:nil];
  }
}

- (void) moviePlayerPlaybackDidFinish: (NSNotification *) notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
  MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
  if (finishReason == MPMovieFinishReasonPlaybackError) {
    NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
  }
}

- (void) onMovieImageTap:(id)sender {
  [self performSegueWithIdentifier:@"photoDetail" sender:self];
//  UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//  PhotoViewController *photoController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PhotoDetail"];
//  photoController.photoURL = self.movie.posterURL;
//  [self.navigationController pushViewController:photoController animated:YES];
}

#pragma mark - Formatter Functions
- (NSString *) getFormattedRating {
  NSString *ratingString;
  float rating = 0.0;
  if ([self.movie.popularity floatValue] < 50.0) {
    float newPopularity = [self.movie.popularity floatValue] + 300;
    rating = (newPopularity / MOVIE_TOP_RATING) * 100;
  }
  else if ([self.movie.popularity floatValue] < 100 && [self.movie.popularity floatValue] >=50) {
    float newPopularity = [self.movie.popularity floatValue] + 200;
    rating = (newPopularity / MOVIE_TOP_RATING) * 100;
  }
  else {
    rating = ([self.movie.popularity floatValue] / MOVIE_TOP_RATING) * 100;
  }
  ratingString = [NSString stringWithFormat:@"%d", (int)roundf(rating)];
  return ratingString;
}

- (NSString *) getFormattedDuration {
  NSString *duration;
  int hours = [self.movie.duration intValue] / 60;
  int minutes = [self.movie.duration intValue] % 60;
  
  duration = [NSString stringWithFormat:@"%d h %d mins", hours, minutes];
  return duration;
}


#pragma mark - Update View
- (void) updateMovieDetails {
  NSString *highResImageUrlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", self.movie.posterPath];
  NSURL *highResImageURL = [NSURL URLWithString:highResImageUrlString];
  NSURLRequest *highResImageRequest = [[NSURLRequest alloc] initWithURL:highResImageURL];
  
  NSString *lowResImageUrlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w45%@", self.movie.posterPath];
  NSURL *lowResImageURL = [NSURL URLWithString:lowResImageUrlString];
  NSURLRequest *lowResImageRequest = [[NSURLRequest alloc] initWithURL:lowResImageURL];

  
  [self.posterView
   setImageWithURLRequest:lowResImageRequest
   placeholderImage:[UIImage imageNamed:@"no_image"]
   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull smallImage) {
     
     self.posterView.alpha = 0.0;
     self.posterView.image = smallImage;
     
     [UIView animateWithDuration:0.3 animations:^{
       self.posterView.alpha = 1.0;
     } completion:^(BOOL finished) {
       [self.posterView
        setImageWithURLRequest:highResImageRequest
        placeholderImage:smallImage
        success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull largeImage) {
          self.posterView.image = largeImage;
        }
        failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
          
        }];
     }];
   }
   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
     
   }];
  
  
  self.titleLabel.text = self.movie.title;
  [self.titleLabel sizeToFit];
  
  self.ratingLabel.text = [NSString stringWithFormat:@"%@ %%", [self getFormattedRating]];
  [self.ratingLabel sizeToFit];
  self.durationLabel.text = [NSString stringWithFormat:@"%@", [self getFormattedDuration]];
  
  self.descriptionLabel.text = self.movie.movieDescription;
  [self.descriptionLabel sizeToFit];
  
  CGFloat totalHeight = 0.0f;
  
  for (UIView *view in self.detailContentView.subviews) {
    totalHeight += view.frame.size.height;
  }
  
  CGRect contentViewFrame = self.detailContentView.frame;
  contentViewFrame.size.height = totalHeight;
  self.detailContentView.frame = contentViewFrame;

  CGPoint point = [self.detailContentView convertPoint:self.detailScrollView.center toView:self.detailContentView];
  self.detailScrollView.contentSize = CGSizeMake(self.detailContentView.frame.size.width, self.detailContentView.frame.size.height + point.y);
}

#pragma mark - Network Request
- (void) fetchMovieById {
  NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
  
  NSString *urlString = [NSString stringWithFormat: @"https://api.themoviedb.org/3/movie/%ld?api_key=%@&append_to_response=videos", (long)[self.movie.id integerValue], apiKey];
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
  
  NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (!error) {
      NSError *jsonError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      
      NSLog(@"Response: %@", responseDictionary);
      NSDictionary *videos = responseDictionary[@"videos"];
      NSArray *results = videos[@"results"];
      
      NSMutableArray *videoIdKeys = [NSMutableArray array];
      for (NSDictionary *result in results) {
        NSString *type = result[@"type"];
        NSString *site = result[@"site"];
        if ([type isEqualToString:@"Trailer"] && [site isEqualToString:@"YouTube"]) {
          NSString *vidKey = result[@"key"];
          [videoIdKeys addObject:vidKey];
        }
      }
      if (videoIdKeys.count > 0) {
        self.videoButton.hidden = NO;
        self.watchTrailerLabel.hidden = NO;
        self.movie.videoId = videoIdKeys[0];
      }

      self.movie.duration = responseDictionary[@"runtime"];
      
      [self updateMovieDetails];
    }
    else {
      NSLog(@"Error Occurred %@", error.description);
    }
  }];
  
  [task resume];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"photoDetail"]) {
    PhotoViewController *photoController = [segue destinationViewController];
    photoController.photoURL = self.movie.posterURL;
  }
}


@end
