//
//  MovieCell.h
//  Flicks
//
//  Created by Abhishek Prabhudesai on 1/23/17.
//  Copyright © 2017 Abhishek Prabhudesai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;

@end
