//
//  ITBAddPhotoCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBAddPhotoCell.h"

@implementation ITBAddPhotoCell

#pragma mark - IBActions

- (IBAction)actionRemove:(UIButton *)sender {
    
    [self.delegate addPhotoCellDidTapRemove:self forCollectionType:self.collectionType];
}

@end
