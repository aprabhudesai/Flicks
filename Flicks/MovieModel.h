//
//  MovieModel.h
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/23/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *movieDescription;
@property (nonatomic, strong) NSString *posterPath;
@property (nonatomic, strong) NSURL *posterURL;
@property (nonatomic, strong) NSDate *releaseDate;
@property (nonatomic, strong) NSNumber *voteAverage;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSString *videoId;

- (instancetype) initWithDictionary: (NSDictionary *) dictionary;

@end
