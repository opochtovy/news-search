//
//  ITBNewsCell.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITBNews, ITBNewsCell;

@protocol ITBNewsCellDelegate <NSObject>

- (void)newsCellDidTapAdd:(ITBNewsCell *) cell;
- (void)newsCellDidTapSubtract:(ITBNewsCell *) cell;
- (void)newsCellDidTapDetail:(ITBNewsCell *) cell;

@end

@interface ITBNewsCell : UITableViewCell

@property (nonatomic, weak) id <ITBNewsCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIButton *addLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *subtractLikeButton;

- (IBAction)actionAddLike:(UIButton *)sender;
- (IBAction)actionSubtractLike:(UIButton *)sender;
- (IBAction)actionShowNewsPage:(UIButton *)sender;

@end
