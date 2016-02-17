//
//  ITBCategoryCD+CoreDataProperties.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBCategoryCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface ITBCategoryCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<ITBNewsCD *> *news;
@property (nullable, nonatomic, retain) NSSet<ITBUserCD *> *signedUsers;

@end

@interface ITBCategoryCD (CoreDataGeneratedAccessors)

- (void)addNewsObject:(ITBNewsCD *)value;
- (void)removeNewsObject:(ITBNewsCD *)value;
- (void)addNews:(NSSet<ITBNewsCD *> *)values;
- (void)removeNews:(NSSet<ITBNewsCD *> *)values;

- (void)addSignedUsersObject:(ITBUserCD *)value;
- (void)removeSignedUsersObject:(ITBUserCD *)value;
- (void)addSignedUsers:(NSSet<ITBUserCD *> *)values;
- (void)removeSignedUsers:(NSSet<ITBUserCD *> *)values;

@end

NS_ASSUME_NONNULL_END
