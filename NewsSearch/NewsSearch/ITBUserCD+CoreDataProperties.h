//
//  ITBUserCD+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBUserCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBUserCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<ITBNewsCD *> *createdNews;
@property (nullable, nonatomic, retain) NSSet<ITBNewsCD *> *likedNews;
@property (nullable, nonatomic, retain) NSSet<ITBCategoryCD *> *selectedCategories;

@end

@interface ITBUserCD (CoreDataGeneratedAccessors)

- (void)addCreatedNewsObject:(ITBNewsCD *)value;
- (void)removeCreatedNewsObject:(ITBNewsCD *)value;
- (void)addCreatedNews:(NSSet<ITBNewsCD *> *)values;
- (void)removeCreatedNews:(NSSet<ITBNewsCD *> *)values;

- (void)addLikedNewsObject:(ITBNewsCD *)value;
- (void)removeLikedNewsObject:(ITBNewsCD *)value;
- (void)addLikedNews:(NSSet<ITBNewsCD *> *)values;
- (void)removeLikedNews:(NSSet<ITBNewsCD *> *)values;

- (void)addSelectedCategoriesObject:(ITBCategoryCD *)value;
- (void)removeSelectedCategoriesObject:(ITBCategoryCD *)value;
- (void)addSelectedCategories:(NSSet<ITBCategoryCD *> *)values;
- (void)removeSelectedCategories:(NSSet<ITBCategoryCD *> *)values;

@end

NS_ASSUME_NONNULL_END
