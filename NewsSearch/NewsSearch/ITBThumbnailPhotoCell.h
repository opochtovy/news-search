//
//  ITBThumbnailPhotoCell.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITBPhoto;

@interface ITBThumbnailPhotoCell : UICollectionViewCell

@property (strong, nonatomic) ITBPhoto *thumbnailPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
