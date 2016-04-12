//
//  ITBActiveNewsCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 01.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBActiveNewsCell.h"
#import "ITBNewsCellDelegate.h"

@implementation ITBActiveNewsCell

#pragma mark - IBActions

- (IBAction)actionAddLike:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidTapAdd:self];
}

- (IBAction)actionSubtractLike:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidTapSubtract:self];
}

- (IBAction)actionShowNewsPage:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidTapDetail:self];
}

- (IBAction)actionAddToFavourites:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidAddToFavourites:self];
}

- (IBAction)actionHideButtons:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidSelectHide:self];
}

- (IBAction)postToTwitter:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidTapTweetButton:self];
}

- (IBAction)postToFacebook:(UIButton *)sender {
    
    [self.activeDelegate newsCellDidTapFacebookButton:self];
}

@end
