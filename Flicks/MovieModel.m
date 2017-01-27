//
//  MovieModel.m
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/23/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  
  if (self) {
    self.id = dictionary[@"id"];
    self.title = dictionary[@"original_title"];
    self.movieDescription = dictionary[@"overview"];
    self.posterPath = dictionary[@"poster_path"];
    NSString *urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@", dictionary[@"poster_path"]];
    self.posterURL = [NSURL URLWithString:urlString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *releaseDate = [dateFormatter dateFromString:dictionary[@"release_date"]];
    self.releaseDate = releaseDate;
    self.voteAverage = dictionary[@"vote_average"];
    self.popularity = dictionary[@"popularity"];
  }

  return self;
}

@end
