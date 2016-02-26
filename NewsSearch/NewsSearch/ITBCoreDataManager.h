//
//  ITBCoreDataManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class ITBUser;

@interface ITBCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId;
- (NSArray* )fetchAllCategories;

- (NSArray *)allObjectsForName:(NSString* ) entityName; // universal fetching by entityName
- (void) printAllObjectsForName:(NSString* ) entityName;

- (NSArray* )addNewsToLocalDBFromLoadedArray:(NSArray* ) dicts;
- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts;

- (void) addRelationsToLocalDBFromNewsDictsArray:(NSArray* ) newsDicts
                                    forNewsArray:(NSArray* ) newsArray
                          fromCategoryDictsArray:(NSArray* ) categoryDicts
                              forCategoriesArray:(NSArray* ) categoriesArray
                                         forUser: (ITBUser* ) currentUser
                                       onSuccess:(void(^)(BOOL isSuccess)) success;

- (void)deleteAllObjects;
- (void)deleteObjectsInArray:(NSArray* ) array;

@end
