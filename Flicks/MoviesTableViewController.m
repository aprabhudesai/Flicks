//
//  MoviesTableViewController.m
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/23/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import "MoviesTableViewController.h"
#import "MovieCell.h"
#import "MovieModel.h"
#import "MovieDetailViewController.h"
#import "MovieCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <KVNProgress/KVNProgress.h>

static NSString *NOW_PLAYING = @"nowPlayingMovies";
static NSString *TOP_RATED = @"topRatedMovies";

@interface MoviesTableViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIView *networkErrorView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) NSArray<MovieModel *> *moviesList;
@property (strong, nonatomic) NSString *type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *movieCollectionView;

- (void) fetchMovies;
- (void) createNetworkErrorView;

@end

@implementation MoviesTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.movieCollectionView.hidden = YES;

  [self createNetworkErrorView];

  KVNProgressConfiguration *config = [[KVNProgressConfiguration alloc] init];
  config.minimumDisplayTime = 1000.0f;
  
  [KVNProgress setConfiguration:config];
  
  // Adds a status below the circle
  [KVNProgress show];
  
  self.movieTableView.dataSource = self;
  self.movieTableView.delegate = self;
  self.movieCollectionView.dataSource = self;
  self.movieCollectionView.delegate = self;
  
  if ([self.restorationIdentifier isEqualToString:NOW_PLAYING]) {
    self.type = @"now_playing";
  }
  else {
    self.type = @"top_rated";
  }
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
  [self.movieTableView insertSubview:self.refreshControl atIndex:0];

  [self.viewTypeSegmentedControl addTarget:self action:@selector(onViewTypeChange) forControlEvents:UIControlEventValueChanged];
  
  [self fetchMovies];
  //[self.movieTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"movieCell"];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.moviesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
//  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"movieCell"];
//  cell.textLabel.text = [self.moviesList objectAtIndex:indexPath.row];

  
  MovieModel *movie = [self.moviesList objectAtIndex:indexPath.row];
  
  MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
  cell.titleLabel.text = movie.title;
  [cell.titleLabel sizeToFit];
  cell.overviewLabel.text = movie.movieDescription;
  [cell.overviewLabel sizeToFit];
  cell.posterImage.contentMode = UIViewContentModeScaleAspectFit;
  
  NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:movie.posterURL];
  [cell.posterImage
   setImageWithURLRequest:urlRequest
   placeholderImage:nil
   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
     if (response) {
       // Image was not cached
       cell.posterImage.alpha = 0.0;
       cell.posterImage.image = image;
       [UIView animateWithDuration:1.0 animations:^{
         cell.posterImage.alpha = 1.0;
       }];
     }
     else {
       cell.posterImage.image = image;
     }
   }
   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
    cell.posterImage.image = [UIImage imageNamed:@"no_image"];
  }];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MovieCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  UIView *bgView = [[UIView alloc] init];
  bgView.backgroundColor = [UIColor colorWithRed:(218.0/255.0) green:(235.0/255.0) blue:(250.0/255.0) alpha:0.9];
  cell.selectedBackgroundView = bgView;
}

#pragma mark - Collection View Methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionMovieCell" forIndexPath:indexPath];
  
  MovieModel *selectedMovie = [self.moviesList objectAtIndex:indexPath.row];
  UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (self.movieCollectionView.bounds.size.width / 3) - 5, (self.movieCollectionView.bounds.size.width / 3) - 5)];
  [photoImageView setImageWithURL:selectedMovie.posterURL];
  
  [cell addSubview:photoImageView];
  return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.moviesList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake((self.movieCollectionView.bounds.size.width / 3) - 5, (self.movieCollectionView.bounds.size.width / 3) - 5);
}
//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 1.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 1.0;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  [super prepareForSegue:segue sender:sender];
  NSIndexPath *selectedMovieIndexPath;
  
  if ([segue.identifier isEqualToString:@"tableViewSegue"]) {
   MovieCell *movieCell = sender;
   selectedMovieIndexPath = [self.movieTableView indexPathForCell:movieCell];
  }
  else if ([segue.identifier isEqualToString:@"collectionViewSegue"]) {
    MovieCollectionViewCell *collectionMovieCell = sender;
    selectedMovieIndexPath = [self.movieCollectionView indexPathForCell:collectionMovieCell];
  }
  
  MovieModel *selectedMovie = self.moviesList[selectedMovieIndexPath.row];
  MovieDetailViewController *destinationController = [segue destinationViewController];
  
  destinationController.movie = selectedMovie;
}

#pragma mark - Refresh Control Methods
- (void) onRefresh {
  self.networkErrorView.hidden = YES;
  [self fetchMovies];
}

- (void) onViewTypeChange {
  if (self.viewTypeSegmentedControl.selectedSegmentIndex == 0) {
    self.movieTableView.hidden = NO;
    self.movieCollectionView.hidden = YES;
  }
  else {
    self.movieTableView.hidden = YES;
    self.movieCollectionView.hidden = NO;
  }
}

- (void)createNetworkErrorView {
  self.networkErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.movieTableView.bounds.size.width, 50)];
  [self.networkErrorView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];

  self.networkErrorView.hidden = YES;

  UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.networkErrorView.bounds.size.width/2 - 50, 13, 200, 20)];
  errorLabel.text = @"Network Error";
  [errorLabel setTextColor:[UIColor whiteColor]];
  
  UIImageView *errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.networkErrorView.bounds.size.width/2 - 95, 5 , 32, 32)];
  errorImageView.image = [[UIImage imageNamed:@"warning"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [errorImageView setTintColor:[UIColor whiteColor]];
  
  [self.networkErrorView addSubview:errorImageView];
  [self.networkErrorView addSubview:errorLabel];
  [self.movieTableView addSubview:self.networkErrorView];
}

#pragma mark - Movies API Call
- (void) fetchMovies {
  NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
  
  NSString *urlString = [NSString stringWithFormat: @"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.type, apiKey];
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
  
  NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    [KVNProgress dismiss];
    if (!error) {
      NSError *jsonError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      //NSLog(@"Response %@", responseDictionary);
      
      NSArray *results = responseDictionary[@"results"];
      NSMutableArray *movies = [NSMutableArray array];
      
      for (NSDictionary *result in results) {
        MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
        [movies addObject:model];
      }
      self.moviesList = movies;

      [self.movieTableView reloadData];
      [self.movieCollectionView reloadData];
    }
    else {
      NSLog(@"Error Occurred %@", error.description);
      self.networkErrorView.hidden = NO;
    }
    [self.refreshControl endRefreshing];
  }];
  
  [task resume];
}


@end
