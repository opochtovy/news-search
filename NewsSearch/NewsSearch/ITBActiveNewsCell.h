//
//  ITBActiveNewsCell.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 01.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBNewsCellDelegate;

@interface ITBActiveNewsCell : UITableViewCell

@property (nonatomic, weak) id <ITBNewsCellDelegate> activeDelegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIButton *addLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *subtractLikeButton;

@end
