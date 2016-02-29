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

// main-thread context
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

// background-thread context
@property (readonly, strong, nonatomic) NSManagedObjectContext *bgManagedObjectContext;

- (NSManagedObjectContext* )getContextForBGTask;

- (void)saveMainContext;
- (void)saveContextForBGTask:(NSManagedObjectContext *)bgTaskContext;

- (void) saveCurrentContext:(NSManagedObjectContext *) context;

- (NSManagedObjectContext* )getCurrentThreadContext;

// universal fetch method
- (NSArray*)getObjectsOfType:(NSString*) type
         withSortDescriptors:(NSArray*) descriptors
                andPredicate:(NSPredicate*) predicate
                   inContext:(NSManagedObjectContext *) context;

- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId;
- (NSArray* )fetchAllCategories;

- (NSArray *)allObjectsForName:(NSString* ) entityName; // universal fetching by entityName
- (void) printAllObjectsForName:(NSString* ) entityName;

- (NSArray* )addNewsToLocalDBFromLoadedArray:(NSArray* ) dicts;
- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts;

// using context
- (NSArray* )addNewsToLocalDBFromLoadedArray:(NSArray* ) dicts
                                usingContext:(NSManagedObjectContext* ) context;
- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts
                                      usingContext:(NSManagedObjectContext* ) context;
- (void) addRelationsToLocalDBFromNewsDictsArray:(NSArray* ) newsDicts
                                    forNewsArray:(NSArray* ) newsArray
                          fromCategoryDictsArray:(NSArray* ) categoryDicts
                              forCategoriesArray:(NSArray* ) categoriesArray
                                         forUser: (ITBUser* ) currentUser
                                    usingContext:(NSManagedObjectContext* ) context
                                       onSuccess:(void(^)(BOOL isSuccess)) success;

- (NSArray *)allObjectsForName:(NSString* ) entityName
                  usingContext:(NSManagedObjectContext* ) context; // universal fetching by entityName
- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId
                            usingContext:(NSManagedObjectContext* ) context;

- (void)deleteObjectsInArray:(NSArray* ) array
                usingContext:(NSManagedObjectContext* ) context;
// end using context

- (void) addRelationsToLocalDBFromNewsDictsArray:(NSArray* ) newsDicts
                                    forNewsArray:(NSArray* ) newsArray
                          fromCategoryDictsArray:(NSArray* ) categoryDicts
                              forCategoriesArray:(NSArray* ) categoriesArray
                                         forUser: (ITBUser* ) currentUser
                                       onSuccess:(void(^)(BOOL isSuccess)) success;

- (void)deleteAllObjects;
- (void)deleteObjectsInArray:(NSArray* ) array;
- (void)deleteAllUsers;

@end
