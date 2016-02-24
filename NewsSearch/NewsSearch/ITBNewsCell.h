//
//  ITBNewsCell.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBNewsCellDelegate;

@interface ITBNewsCell : UITableViewCell

@property (nonatomic, weak) id <ITBNewsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIButton *addLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *subtractLikeButton;

@end

@protocol ITBNewsCellDelegate <NSObject>

- (void)newsCellDidTapAdd:(ITBNewsCell *) cell;
- (void)newsCellDidTapSubtract:(ITBNewsCell *) cell;
- (void)newsCellDidTapDetail:(ITBNewsCell *) cell;

@end
