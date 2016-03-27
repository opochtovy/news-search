//
//  ITBPhoto+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *newsWithPhoto;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *newsWithThumbnailPhoto;

@end

@interface ITBPhoto (CoreDataGeneratedAccessors)

- (void)addNewsWithPhotoObject:(ITBNews *)value;
- (void)removeNewsWithPhotoObject:(ITBNews *)value;
- (void)addNewsWithPhoto:(NSSet<ITBNews *> *)values;
- (void)removeNewsWithPhoto:(NSSet<ITBNews *> *)values;

- (void)addNewsWithThumbnailPhotoObject:(ITBNews *)value;
- (void)removeNewsWithThumbnailPhotoObject:(ITBNews *)value;
- (void)addNewsWithThumbnailPhoto:(NSSet<ITBNews *> *)values;
- (void)removeNewsWithThumbnailPhoto:(NSSet<ITBNews *> *)values;

@end

NS_ASSUME_NONNULL_END
