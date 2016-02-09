//
//  ITBNewsCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsCell.h"

#import "ITBNews.h"

CGFloat const offset = 5.f;
CGFloat const vertOffset = 10.f;
CGFloat const detailsButtonSide = 22.f;
CGFloat const ratingWidth = 50.f;
CGFloat const minRatingHeight = 30.f;
CGFloat const addHeight = 20.f;

CGFloat const sizeOfTitleFont = 14.f;
CGFloat const sizeOfCategoryFont = 12.f;

@implementation ITBNewsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) heightForNews:(ITBNews *)news {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    CGFloat windowWidth = window.bounds.size.width;
    
    // title
    UIFont *titleFont = [UIFont systemFontOfSize:sizeOfTitleFont];
    
    CGFloat titleWidth = windowWidth - 4 * offset - ratingWidth - detailsButtonSide;
    
    CGRect titleRect = [ITBNewsCell countRectForText:news.title
                                        forWidth:titleWidth
                                             forFont:titleFont];
    
    // category
    UIFont *categoryFont = [UIFont boldSystemFontOfSize:sizeOfCategoryFont];
    
    CGRect categoryRect = [ITBNewsCell countRectForText:news.category
                                            forWidth:titleWidth
                                                forFont:categoryFont];
    
    // rating column height
    CGFloat ratingColumnHeight = 4 * offset + 2 * addHeight + minRatingHeight;
    
    CGFloat maxHeight = MAX(CGRectGetHeight(titleRect) + CGRectGetHeight(categoryRect) + 3 * vertOffset,
                            ratingColumnHeight);
    
//    return CGRectGetHeight(titleRect) + CGRectGetHeight(categoryRect) + 3 * offset;
    return maxHeight;
}

+ (CGRect) countRectForText:(NSString *) text forWidth:(CGFloat) width forFont:(UIFont *) font {
    
    NSDictionary *attributes = [ITBNewsCell attributesForTextWithFont:font];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect;
}

+ (NSDictionary *) attributesForTextWithFont:(UIFont *) font {
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentJustified];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor grayColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                shadow, NSShadowAttributeName,
                                paragraph, NSParagraphStyleAttributeName, nil];
    return attributes;
}

- (void) countFramesForNews:(ITBNews *)news {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    CGFloat windowWidth = window.bounds.size.width;
    
    // title
    UIFont *titleFont = [UIFont systemFontOfSize:sizeOfTitleFont];
    
    CGFloat titleWidth = windowWidth - 4 * offset - ratingWidth - detailsButtonSide;
    
    CGRect titleRect = [ITBNewsCell countRectForText:news.title
                                            forWidth:titleWidth
                                             forFont:titleFont];
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                            self.titleLabel.frame.origin.y,
                                            CGRectGetWidth(titleRect),
                                            CGRectGetHeight(titleRect));
    
    // category
    UIFont *categoryFont = [UIFont boldSystemFontOfSize:sizeOfCategoryFont];
    
    CGRect categoryRect = [ITBNewsCell countRectForText:news.category
                                               forWidth:titleWidth
                                                forFont:categoryFont];
    
    self.categoryLabel.frame = CGRectMake(self.categoryLabel.frame.origin.x,
                                       self.categoryLabel.frame.origin.y,
                                       CGRectGetWidth(titleRect),
                                          CGRectGetHeight(categoryRect));
    
    // rating
    CGFloat ratingLabelHeight = CGRectGetHeight(titleRect) + CGRectGetHeight(categoryRect) + 3 * vertOffset - 4 * offset - 2 * addHeight;
    
    CGFloat ratingHeight = MAX(ratingLabelHeight, minRatingHeight);
    
    self.ratingLabel.frame = CGRectMake(self.ratingLabel.frame.origin.x,
                                        self.ratingLabel.frame.origin.y,
                                        ratingWidth,
                                        ratingHeight);
}

@end
