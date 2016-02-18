//
//  ITBNewsCD+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 18.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBNewsCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBNewsCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *newsURL;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSNumber *isLikedByCurrentUser;
@property (nullable, nonatomic, retain) ITBUserCD *author;
@property (nullable, nonatomic, retain) ITBCategoryCD *category;
@property (nullable, nonatomic, retain) NSSet<ITBUserCD *> *likeAddedUsers;

@end

@interface ITBNewsCD (CoreDataGeneratedAccessors)

- (void)addLikeAddedUsersObject:(ITBUserCD *)value;
- (void)removeLikeAddedUsersObject:(ITBUserCD *)value;
- (void)addLikeAddedUsers:(NSSet<ITBUserCD *> *)values;
- (void)removeLikeAddedUsers:(NSSet<ITBUserCD *> *)values;

@end

NS_ASSUME_NONNULL_END
