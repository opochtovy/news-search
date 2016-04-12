//
//  ITBCoreDataManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class ITBUser, ITBPhoto;

@interface ITBCoreDataManager : NSObject

- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSManagedObjectContext *)mainManagedObjectContext;
- (NSManagedObjectContext *)bgManagedObjectContext;

- (void)saveBgContext;

- (NSArray *)fetchObjectsForName:(NSString *)entityName withSortDescriptor:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (NSArray *)allObjectsForName:(NSString *)entityName usingContext:(NSManagedObjectContext *)context;

- (void)fetchObjectsForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate withCompletionHandler:(void(^)(NSArray *resultArray))completionHandler;

- (void)addRelationsToLocalDBFromNewsDictsArray:(NSArray *)newsDicts forNewsArray:(NSArray *)newsArray fromCategoryDictsArray:(NSArray *)categoryDicts forCategoriesArray:(NSArray *)categoriesArray fromPhotoDictsArray:(NSArray *)allPhotoDicts forPhotosArray:(NSArray *)allPhotosArray forUser: (ITBUser *)currentUser usingContext:(NSManagedObjectContext *)context onSuccess:(void(^)(BOOL isSuccess))success;

- (void)setAuthorizedUserForObjectId:(NSString *)objectId withDictionary:(NSDictionary *)dict withCompletionHandler:(void(^)(ITBUser *user))completionHandler;

@end
