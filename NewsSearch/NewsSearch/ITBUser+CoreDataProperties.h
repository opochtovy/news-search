//
//  ITBUser+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 01.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *code;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *error;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *sessionToken;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *createdNews;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *likedNews;
@property (nullable, nonatomic, retain) NSSet<ITBCategory *> *selectedCategories;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *favouriteNews;

@end

@interface ITBUser (CoreDataGeneratedAccessors)

- (void)addCreatedNewsObject:(ITBNews *)value;
- (void)removeCreatedNewsObject:(ITBNews *)value;
- (void)addCreatedNews:(NSSet<ITBNews *> *)values;
- (void)removeCreatedNews:(NSSet<ITBNews *> *)values;

- (void)addLikedNewsObject:(ITBNews *)value;
- (void)removeLikedNewsObject:(ITBNews *)value;
- (void)addLikedNews:(NSSet<ITBNews *> *)values;
- (void)removeLikedNews:(NSSet<ITBNews *> *)values;

- (void)addSelectedCategoriesObject:(ITBCategory *)value;
- (void)removeSelectedCategoriesObject:(ITBCategory *)value;
- (void)addSelectedCategories:(NSSet<ITBCategory *> *)values;
- (void)removeSelectedCategories:(NSSet<ITBCategory *> *)values;

- (void)addFavouriteNewsObject:(ITBNews *)value;
- (void)removeFavouriteNewsObject:(ITBNews *)value;
- (void)addFavouriteNews:(NSSet<ITBNews *> *)values;
- (void)removeFavouriteNews:(NSSet<ITBNews *> *)values;

@end

NS_ASSUME_NONNULL_END
