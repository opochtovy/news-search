//
//  ITBNewsCellDelegate.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITBNewsCellDelegate <NSObject>

- (void)newsCellDidTapAdd:(UITableViewCell *)cell;
- (void)newsCellDidTapSubtract:(UITableViewCell *)cell;
- (void)newsCellDidTapDetail:(UITableViewCell *)cell;

@optional

- (void)newsCellDidSelectTitle:(UITableViewCell *)cell;
- (void)newsCellDidSelectHide:(UITableViewCell *)cell;

- (void)newsCellDidAddToFavourites:(UITableViewCell *)cell;

- (void)newsCellDidTapTweetButton:(UITableViewCell *)cell;
- (void)newsCellDidTapFacebookButton:(UITableViewCell *)cell;

@end
