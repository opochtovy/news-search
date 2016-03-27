//
//  ITBThumbnailPhotoCell.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBThumbnailPhotoCell.h"

#import "ITBPhoto.h"
#import "ITBNewsAPI.h"

#import "ITBUtils.h"

@implementation ITBThumbnailPhotoCell

- (void)setThumbnailPhoto:(ITBPhoto *)thumbnailPhoto {
    
    if (_thumbnailPhoto != thumbnailPhoto) {
        
        _thumbnailPhoto = thumbnailPhoto;
    }
    
    [self.activityIndicator startAnimating];

    self.imageView.image = nil;
    
    __weak ITBThumbnailPhotoCell* weakSelf = self;
    
    if (thumbnailPhoto.imageData == nil) {
        
        [self.activityIndicator startAnimating];
        
        [[ITBNewsAPI sharedInstance] loadImageForUrlString:_thumbnailPhoto.url onSuccess:^(NSData *data) {
            
            if (data != nil) {
                
                UIImage *image = [[UIImage alloc] initWithData:data];
                _thumbnailPhoto.imageData = data;
                
                NSError *error = nil;
                BOOL saved = [[ITBNewsAPI sharedInstance].mainManagedObjectContext save:&error];
                
                if (!saved) {
                    
                    NSLog(@"%@ %@\n%@", contextSavingError, [error localizedDescription], [error userInfo]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.imageView.image = image;
                    [weakSelf.activityIndicator stopAnimating];
                });
            }
            
        }];
        
    } else {
        
        self.imageView.image = [UIImage imageWithData:thumbnailPhoto.imageData];
    }
    
}

@end
