//
//  ITBThumbnailPhotoCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBThumbnailPhotoCell.h"

#import "ITBPhoto.h"

@implementation ITBThumbnailPhotoCell

- (void) setThumbnailPhoto:(ITBPhoto *)thumbnailPhoto {
    
    if (_thumbnailPhoto != thumbnailPhoto) {
        
        _thumbnailPhoto = thumbnailPhoto;
    }
    
    [self.activityIndicator startAnimating];
    
    self.imageView.image = nil;
    
    __weak ITBThumbnailPhotoCell* weakSelf = self;
    
    [_thumbnailPhoto setImageWithURL:_thumbnailPhoto.url onSuccess:^(UIImage * _Nonnull image) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            weakSelf.imageView.image = image;
            [weakSelf.activityIndicator stopAnimating];
        });
    }];
    
}

@end
