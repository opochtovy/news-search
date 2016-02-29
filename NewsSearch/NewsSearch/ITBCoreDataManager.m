//
//  ITBCoreDataManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCoreDataManager.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"

@interface ITBCoreDataManager ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ITBCoreDataManager

@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize bgManagedObjectContext = _bgManagedObjectContext;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init {
    
    self = [super init];
    
    if (self != nil)
    {
    }
    
    return self;
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewsSearch" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsSearch.sqlite"];
    
    NSError *error = nil;
    //    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator == nil) {
        return nil;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)bgManagedObjectContext
{
    if (_bgManagedObjectContext != nil) {
        return _bgManagedObjectContext;
    }
    
    _bgManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_bgManagedObjectContext setParentContext:_mainManagedObjectContext];
    
    return _bgManagedObjectContext;
}

- (NSManagedObjectContext* )getContextForBGTask {
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [context setParentContext:_mainManagedObjectContext];
    
    return context;
}

- (NSManagedObjectContext* )getCurrentThreadContext {
    
    NSManagedObjectContext *result = nil;
    
    if ([NSThread isMainThread]) {
        
        result = _mainManagedObjectContext;
        
    } else {
        
        result = [self getContextForBGTask];
    }
    
    return result;
}

#pragma mark - Core Data Saving support

- (void)saveContextForBGTask:(NSManagedObjectContext *)bgTaskContext {
    
    if (bgTaskContext.hasChanges) {
        
        [bgTaskContext performBlockAndWait:^{
            
            NSError *error = nil;
            [bgTaskContext save:&error];
            
        }];
        
        // Save main context
        [self saveMainContext];
        
    }
}

- (void)saveMainContext {
    
    if (_mainManagedObjectContext.hasChanges) {
        
        [_mainManagedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            [_mainManagedObjectContext save:&error];
            
        }];
    }
}

- (void) saveCurrentContext:(NSManagedObjectContext *) context {
    
    if ([NSThread isMainThread]) {
        
        [self saveMainContext];
        
    } else {
        
        [self saveContextForBGTask:context];
    }
}

// universal fetch method
- (NSArray*)getObjectsOfType:(NSString*) type
         withSortDescriptors:(NSArray*) descriptors
                andPredicate:(NSPredicate*) predicate
                   inContext:(NSManagedObjectContext *) context {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    [request setReturnsObjectsAsFaults:NO];
    
    NSEntityDescription* desc = [NSEntityDescription entityForName:type inManagedObjectContext:context];
    
    [request setEntity:desc];
    
    if (descriptors != nil)
        [request setSortDescriptors:descriptors];
    
    if (predicate != nil)
        [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* result = nil;
    
    result = [context executeFetchRequest:request error:&error];
    
    if ((result == nil) || (error != nil))
        
        return nil;
    
    return result;
}

- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId {
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBUser"
                                        inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *currentUserArray = [context executeFetchRequest:request error:&requestError];
    
    if (requestError != nil) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return [currentUserArray firstObject];
    
}

- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId
                            usingContext:(NSManagedObjectContext* ) context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBUser"
                                        inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *currentUserArray = [context executeFetchRequest:request error:&requestError];
    
    if (requestError != nil) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return [currentUserArray firstObject];
    
}

- (NSArray* )fetchAllCategories {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBCategory"
                                        inManagedObjectContext:self.mainManagedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.mainManagedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError != nil) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}

- (NSArray *)allObjectsForName:(NSString* ) entityName {
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:entityName
                                        inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [context executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}

- (NSArray *)allObjectsForName:(NSString* ) entityName
                   usingContext:(NSManagedObjectContext* ) context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:entityName
                                        inManagedObjectContext:context];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [context executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

- (void)deleteAllObjectsForName:(NSString* ) entityName {
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    NSArray *allObjects = [self allObjectsForName:entityName usingContext:context];
    
    for (id object in allObjects) {
        
        [context deleteObject:object];
    }
    
    [self saveCurrentContext:context];
}

- (void)deleteAllObjects
{
    
    [self deleteAllObjectsForName:@"ITBNews"];
    [self deleteAllObjectsForName:@"ITBCategory"];
}

- (void)deleteAllUsers
{
    
    [self deleteAllObjectsForName:@"ITBUser"];
}

- (void)deleteObjectsInArray:(NSArray* ) array
{
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    for (id object in array) {
        [context deleteObject:object];
    }
}

- (void)deleteObjectsInArray:(NSArray* ) array
                usingContext:(NSManagedObjectContext* ) context
{
    for (id object in array) {
        [context deleteObject:object];
    }
}

- (void) printAllObjects {
    
    [self printAllObjectsForName:@"ITBNews"];
    [self printAllObjectsForName:@"ITBCategory"];
    [self printAllObjectsForName:@"ITBUser"];
}

- (void) printAllObjectsForName:(NSString* ) entityName {
    
    NSArray *allObjects = [self allObjectsForName:entityName];
    
    [self printArray:allObjects];
    
}

- (void)printArray:(NSArray *)array {
    
    for (id object in array) {
        
        if ([object isKindOfClass:[ITBNews class]]) {
            
            ITBNews *newsItem = (ITBNews *)object;
            NSLog(@"NEWS title : %@ and URL %@, created at : %@, updated at : %@ AND category = %@ AND author = %@ AND number of likeAddedUsers = %li AND newsItem.rating = %@", newsItem.title, newsItem.newsURL, newsItem.createdAt, newsItem.updatedAt, newsItem.category.title, newsItem.author.username, (long)[newsItem.likeAddedUsers count], newsItem.rating);
            
        } else if ([object isKindOfClass:[ITBCategory class]]) {
            
            ITBCategory *category = (ITBCategory *)object;
            NSLog(@"CATEGORY title : %@ and objectId = %@ and number of news in that category = %li and number of signed users = %li", category.title, category.objectId, (long)[category.news count], (long)[category.signedUsers count]);
            
        } else if ([object isKindOfClass:[ITBUser class]]) {
            
            ITBUser *user = (ITBUser *)object;
            NSLog(@"USER username : %@ and objectId = %@ and number of created news = %li and number of liked news = %li and number of selected categories = %li", user.username, user.objectId, (long)[user.createdNews count], (long)[user.likedNews count], (long)[user.selectedCategories count]);
            
        }
        
    }
    
}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

#pragma mark - Database creating

- (NSArray* )addNewsToLocalDBFromLoadedArray:(NSArray* ) dicts
{
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in dicts) {
        
        ITBNews* newsItem = [[ITBNews alloc] insertObjectWithDictionary:newsDict inContext:context];
        
        [newsArray addObject:newsItem];
    }
    
    return [newsArray copy];
}

- (NSArray* )addNewsToLocalDBFromLoadedArray:(NSArray* ) dicts
                                usingContext:(NSManagedObjectContext* ) context
{
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in dicts) {
        
        ITBNews* newsItem = [[ITBNews alloc] insertObjectWithDictionary:newsDict inContext:context];
        
        [newsArray addObject:newsItem];
    }
    
    return [newsArray copy];
}

- (NSArray* )updateNewsToLocalDBFromLoadedArray:(NSArray* ) dicts
                                forLocalObjects:(NSArray* ) updatedNewsArray
{
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in dicts) {
        
        ITBNews* newsItem = [updatedNewsArray objectAtIndex:[dicts indexOfObject:newsDict]];
        
        [newsItem updateObjectWithDictionary:newsDict inContext:self.mainManagedObjectContext];
        
        [newsArray addObject:newsItem];
    }
    
    return [newsArray copy];
}

- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts
{
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* catDict in dicts) {
        
        ITBCategory* category = [[ITBCategory alloc] insertObjectWithDictionary:catDict inContext:context];
        
        [categoriesArray addObject:category];
    }
    
    return [categoriesArray copy];
}

- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts
                                      usingContext:(NSManagedObjectContext* ) context
{
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* catDict in dicts) {
        
        ITBCategory* category = [[ITBCategory alloc] insertObjectWithDictionary:catDict inContext:context];
        
        [categoriesArray addObject:category];
    }
    
    return [categoriesArray copy];
    
}

- (void) addRelationsToLocalDBFromNewsDictsArray:(NSArray* ) newsDicts
                                    forNewsArray:(NSArray* ) newsArray
                          fromCategoryDictsArray:(NSArray* ) categoryDicts
                              forCategoriesArray:(NSArray* ) categoriesArray
                                    forUser: (ITBUser* ) currentUser
                                       onSuccess:(void(^)(BOOL isSuccess)) success
{
    
    for (NSDictionary* newsDict in newsDicts) {
        
        ITBNews* newsItem = [newsArray objectAtIndex:[newsDicts indexOfObject:newsDict]];
        
        NSDictionary* authorDict = [newsDict objectForKey:@"author"]; // for newsItem
        NSArray* likeAddedUsersDictsArray = [newsDict objectForKey:@"likeAddedUsers"]; // for newsItem
        NSDictionary* categoryOfNewsItemDict = [newsDict objectForKey:@"category"]; // for newsItem
        
        if ([currentUser.objectId isEqualToString:[authorDict objectForKey:@"objectId"]]) {
            
            newsItem.author = currentUser;
        }
        
        for (NSDictionary* likeAddedUserDict in likeAddedUsersDictsArray) {
            
            if ([currentUser.objectId isEqualToString:[likeAddedUserDict objectForKey:@"objectId"]]) {
                
                [currentUser addLikedNewsObject:newsItem];
            }
        }
    
        for (NSDictionary* categoryDict in categoryDicts) {
            
            ITBCategory* category = [categoriesArray objectAtIndex:[categoryDicts indexOfObject:categoryDict]];
            
            NSArray* signedUsersDictsArray = [categoryDict objectForKey:@"signedUsers"]; // for category
            
            if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:@"objectId"]]) {
                
                newsItem.category = category;
            }
            
            for (NSDictionary* signedUserDict in signedUsersDictsArray) {
                
                if ([currentUser.objectId isEqualToString:[signedUserDict objectForKey:@"objectId"]]) {
                    
                    [currentUser addSelectedCategoriesObject:category];
                    
                }
            }
        }
    }
    
    NSManagedObjectContext* context = [self getCurrentThreadContext];
    [self saveCurrentContext:context];
    
    [self printAllObjects];
    
    success(YES);
}

- (void) addRelationsToLocalDBFromNewsDictsArray:(NSArray* ) newsDicts
                                     forNewsArray:(NSArray* ) newsArray
                           fromCategoryDictsArray:(NSArray* ) categoryDicts
                               forCategoriesArray:(NSArray* ) categoriesArray
                                          forUser: (ITBUser* ) currentUser
                                     usingContext:(NSManagedObjectContext* ) context
                                        onSuccess:(void(^)(BOOL isSuccess)) success
{
    
    for (NSDictionary* newsDict in newsDicts) {
        
        ITBNews* newsItem = [newsArray objectAtIndex:[newsDicts indexOfObject:newsDict]];
        
        NSDictionary* authorDict = [newsDict objectForKey:@"author"]; // for newsItem
        NSArray* likeAddedUsersDictsArray = [newsDict objectForKey:@"likeAddedUsers"]; // for newsItem
        NSDictionary* categoryOfNewsItemDict = [newsDict objectForKey:@"category"]; // for newsItem
        
        if ([currentUser.objectId isEqualToString:[authorDict objectForKey:@"objectId"]]) {
            
            newsItem.author = currentUser;
        }
        
        for (NSString* likeAddedUserObjectId in likeAddedUsersDictsArray) {
            
            if ([currentUser.objectId isEqualToString:likeAddedUserObjectId]) {
                
                [currentUser addLikedNewsObject:newsItem];
                newsItem.isLikedByCurrentUser = @1;
            }
        }
        
        for (NSDictionary* categoryDict in categoryDicts) {
            
            ITBCategory* category = [categoriesArray objectAtIndex:[categoryDicts indexOfObject:categoryDict]];
            
            NSArray* signedUsersDictsArray = [categoryDict objectForKey:@"signedUsers"]; // for category
            
            if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:@"objectId"]]) {
                
                newsItem.category = category;
                
            }
            
            for (NSString* signedUserObjectId in signedUsersDictsArray) {
                
                if ([currentUser.objectId isEqualToString:signedUserObjectId ]) {
                    
                    [currentUser addSelectedCategoriesObject:category];
                    
                }
            }
        }
    }
    
    [self saveContextForBGTask:context];
    
    success(YES);
}

@end
