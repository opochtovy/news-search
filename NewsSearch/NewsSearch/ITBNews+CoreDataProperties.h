//
//  ITBNews+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBNews.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBNews (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *isLikedByCurrentUser;
@property (nullable, nonatomic, retain) NSNumber *isTitlePressed;
@property (nullable, nonatomic, retain) NSString *newsURL;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) ITBUser *author;
@property (nullable, nonatomic, retain) ITBCategory *category;
@property (nullable, nonatomic, retain) NSSet<ITBUser *> *likeAddedUsers;
@property (nullable, nonatomic, retain) NSSet<ITBPhoto *> *photos;
@property (nullable, nonatomic, retain) NSSet<ITBPhoto *> *thumbnailPhotos;
@property (nullable, nonatomic, retain) NSSet<ITBUser *> *toFavouritesAddedUsers;

@end

@interface ITBNews (CoreDataGeneratedAccessors)

- (void)addLikeAddedUsersObject:(ITBUser *)value;
- (void)removeLikeAddedUsersObject:(ITBUser *)value;
- (void)addLikeAddedUsers:(NSSet<ITBUser *> *)values;
- (void)removeLikeAddedUsers:(NSSet<ITBUser *> *)values;

- (void)addPhotosObject:(ITBPhoto *)value;
- (void)removePhotosObject:(ITBPhoto *)value;
- (void)addPhotos:(NSSet<ITBPhoto *> *)values;
- (void)removePhotos:(NSSet<ITBPhoto *> *)values;

- (void)addThumbnailPhotosObject:(ITBPhoto *)value;
- (void)removeThumbnailPhotosObject:(ITBPhoto *)value;
- (void)addThumbnailPhotos:(NSSet<ITBPhoto *> *)values;
- (void)removeThumbnailPhotos:(NSSet<ITBPhoto *> *)values;

- (void)addToFavouritesAddedUsersObject:(ITBUser *)value;
- (void)removeToFavouritesAddedUsersObject:(ITBUser *)value;
- (void)addToFavouritesAddedUsers:(NSSet<ITBUser *> *)values;
- (void)removeToFavouritesAddedUsers:(NSSet<ITBUser *> *)values;

@end

NS_ASSUME_NONNULL_END
