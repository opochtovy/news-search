//
//  ITBNewsCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsCell.h"

#import "ITBNews.h"

@implementation ITBNewsCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionAddLike:(UIButton *)sender {
    
    [self.delegate newsCellDidTapAdd:self];
}

- (IBAction)actionSubtractLike:(UIButton *)sender {
    
    [self.delegate newsCellDidTapSubtract:self];
}

- (IBAction)actionShowNewsPage:(UIButton *)sender {
    
    [self.delegate newsCellDidTapDetail:self];
}
@end
