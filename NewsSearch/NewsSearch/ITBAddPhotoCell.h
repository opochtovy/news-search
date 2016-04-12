//
//  ITBAddPhotoCell.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

typedef enum {
    
    ITBCollectionTypeLargePhotos,
    ITBCollectionTypeThumbnailPhotos
    
} ITBCollectionType;

#import <UIKit/UIKit.h>

@protocol ITBAddPhotoCellDelegate;

@interface ITBAddPhotoCell : UICollectionViewCell

@property (nonatomic, weak) id <ITBAddPhotoCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (assign, nonatomic) ITBCollectionType collectionType;

@end

@protocol ITBAddPhotoCellDelegate <NSObject>

- (void)addPhotoCellDidTapRemove:(ITBAddPhotoCell *)cell forCollectionType:(ITBCollectionType)type;

@end
