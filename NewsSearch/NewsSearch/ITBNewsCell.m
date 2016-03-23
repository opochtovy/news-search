//
//  ITBNewsCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsCell.h"
#import "ITBNewsCellDelegate.h"

@implementation ITBNewsCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

#pragma mark - IBActions

- (IBAction)actionAddLike:(UIButton *)sender {
    
    [self.delegate newsCellDidTapAdd:self];
}

- (IBAction)actionSubtractLike:(UIButton *)sender {
    
    [self.delegate newsCellDidTapSubtract:self];
}

- (IBAction)actionShowNewsPage:(UIButton *)sender {
    
    [self.delegate newsCellDidTapDetail:self];
}


- (IBAction)actionSelectTitle:(UIButton *)sender {
    
    [self.delegate newsCellDidSelectTitle:self];
}

@end
