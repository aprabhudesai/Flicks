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

@interface MoviesTableViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) UIView *networkErrorView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) NSArray<MovieModel *> *moviesList;
@property (strong, nonatomic) NSMutableArray<MovieModel *> *filteredMovies;
@property (strong, nonatomic) NSString *type;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *movieCollectionView;
@property (strong, nonatomic) UISearchController *searchController;

- (void) fetchMovies;
- (void) createNetworkErrorView;

@end

@implementation MoviesTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  
  self.searchController.searchResultsUpdater = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;
  self.searchController.definesPresentationContext = YES;
  self.movieTableView.tableHeaderView = self.searchController.searchBar;
  
  self.navigationItem.title = @"Movies";
//  self.navigationController.navigationBar.layer.backgroundColor = [[UIColor whiteColor] CGColor];
//  self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
//  self.navigationController.navigationBar.layer.shadowRadius = 6.0f;
//  self.navigationController.navigationBar.layer.shadowOpacity = 0.8f;
  
  NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor whiteColor], NSForegroundColorAttributeName,
                                  nil];
  
  NSDictionary *textSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                          [UIFont fontWithName:@"Helvetica-Bold" size:20], NSFontAttributeName,
                                          nil];
  
  // Magnet Color
  //UIColor *tintColor = [UIColor colorWithRed:0.17 green:0.24 blue:0.31 alpha:1.0];
  
  // Pumpkin Color
  //UIColor *tintColor = [UIColor colorWithRed:0.83 green:0.33 blue:0.00 alpha:1.0];
  
  // Carrot Color
  //UIColor *tintColor = [UIColor colorWithRed:0.90 green:0.49 blue:0.13 alpha:1.0];
  
  // Pomegranate Color
  UIColor *tintColor = [UIColor colorWithRed:0.91 green:0.36 blue:0.05 alpha:1.0];
  
  // Set Navigation Bar Attributes
  self.navigationController.navigationBar.titleTextAttributes = textAttributes;
  [self.navigationController.navigationBar setBarTintColor:tintColor];
  [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  
  [self.tabBarController.tabBar setBarTintColor:tintColor];
  [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
  [self.tabBarController.tabBar setUnselectedItemTintColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:0.5]];
  [self.tabBarController.tabBarItem setTitleTextAttributes:textSelectedAttributes forState:UIControlStateNormal];
  [self.tabBarController.tabBarItem setTitleTextAttributes:textSelectedAttributes forState:UIControlStateSelected];

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
  self.searchController.searchBar.delegate = self;
  
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
  if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
    return self.filteredMovies.count;
  }
  return self.moviesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
//  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"movieCell"];
//  cell.textLabel.text = [self.moviesList objectAtIndex:indexPath.row];

  MovieModel *movie;
  if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
    movie = [self.filteredMovies objectAtIndex:indexPath.row];
  }
  else {
    movie = [self.moviesList objectAtIndex:indexPath.row];
  }
  
  MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
  cell.titleLabel.text = movie.title;
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

  [self.searchController.searchBar endEditing:YES];
  [self.searchController setActive:NO];
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

#pragma mark - Search Controller Methods
- (void) filterContentForSearchText: (NSString *)searchText andScope: (NSString *) scope {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@", searchText];
  self.filteredMovies = [NSMutableArray arrayWithArray:[self.moviesList filteredArrayUsingPredicate:predicate]];
  
  [self.movieTableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  [self filterContentForSearchText:searchController.searchBar.text andScope:@"All"];
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
  
  MovieModel *selectedMovie;
  if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
    selectedMovie = self.filteredMovies[selectedMovieIndexPath.row];
  }
  else {
    selectedMovie = self.moviesList[selectedMovieIndexPath.row];
  }
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
