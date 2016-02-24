//
//  ITBCategory+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 24.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSSet<ITBNews *> *news;
@property (nullable, nonatomic, retain) NSSet<ITBUser *> *signedUsers;

@end

@interface ITBCategory (CoreDataGeneratedAccessors)

- (void)addNewsObject:(ITBNews *)value;
- (void)removeNewsObject:(ITBNews *)value;
- (void)addNews:(NSSet<ITBNews *> *)values;
- (void)removeNews:(NSSet<ITBNews *> *)values;

- (void)addSignedUsersObject:(ITBUser *)value;
- (void)removeSignedUsersObject:(ITBUser *)value;
- (void)addSignedUsers:(NSSet<ITBUser *> *)values;
- (void)removeSignedUsers:(NSSet<ITBUser *> *)values;

@end

NS_ASSUME_NONNULL_END
