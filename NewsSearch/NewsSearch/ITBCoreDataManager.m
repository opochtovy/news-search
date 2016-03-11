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
#import "ITBPhoto.h"

@interface ITBCoreDataManager ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *saveManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *syncManagedObjectContext;

@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation ITBCoreDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize saveManagedObjectContext = _saveManagedObjectContext;
@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize syncManagedObjectContext = _syncManagedObjectContext;

#pragma mark - Lifecycle

- (id)init {
    
    self = [super init];
    
    if (self != nil)
    {
        _photos = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewsSearch" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsSearch.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}

// saveContext - used to propegate saves to the persistent store (disk) without blocking the UI
- (NSManagedObjectContext *)saveManagedObjectContext {
    
    if (_saveManagedObjectContext != nil) {
        return _saveManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        
        _saveManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_saveManagedObjectContext performBlockAndWait:^{
            
            [_saveManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
    }
    
    return _saveManagedObjectContext;
}

// mainContext - context for using for the UI
- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    NSManagedObjectContext *saveContext = [self saveManagedObjectContext];
    
    if (saveContext != nil) {
        
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext performBlockAndWait:^{
            
            [_mainManagedObjectContext setParentContext:saveContext];
        }];
    }
    
    return _mainManagedObjectContext;
}

// syncContext - used to do user edits of the data and synchronization tasks
- (NSManagedObjectContext *)syncManagedObjectContext {
    
    if (_syncManagedObjectContext != nil) {
        return _syncManagedObjectContext;
    }
    
    NSManagedObjectContext *saveContext = [self saveManagedObjectContext];
    
    if (saveContext != nil) {
        
        _syncManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_syncManagedObjectContext performBlockAndWait:^{
            
            [_syncManagedObjectContext setParentContext:saveContext];
        }];
    }
    
    return _syncManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveSaveContext {
    
    if (self.saveManagedObjectContext.hasChanges) {
        
        [self.saveManagedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            BOOL saved = [self.saveManagedObjectContext save:&error];
            
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save saveContext due to %@", error);
            }
        }];
        
    }
}

- (void)saveMainContext {
    
    if (self.mainManagedObjectContext.hasChanges) {
        
        [self.mainManagedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            BOOL saved = [self.mainManagedObjectContext save:&error];
            
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save mainContext due to %@", error);
            }
        }];
        
    }
}

- (void)saveSyncContext {
    
    if (self.syncManagedObjectContext.hasChanges) {
        
        [self.syncManagedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            BOOL saved = [self.syncManagedObjectContext save:&error];
            
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save syncContext due to %@", error);
            }
        }];
        
    }
}

- (void) saveCurrentContext:(NSManagedObjectContext *) context {
    
    if (context == self.mainManagedObjectContext) {
        
        [self saveMainContext];
        
    } else if (context == self.syncManagedObjectContext) {
        
        [self saveSyncContext];
        
    }
    
    [self saveSaveContext];
}

#pragma mark - Public

- (NSArray *)fetchObjectsForName:(NSString *)entityName withSortDescriptor:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    
    __block NSArray *result = nil;
    __block NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setReturnsObjectsAsFaults:NO];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:description];
    
    if (descriptors != nil) {
        
        [request setSortDescriptors:descriptors];
    }
    
    if (predicate != nil) {
        
        [request setPredicate:predicate];
    }
    
    [context performBlockAndWait:^{
        
        result = [context executeFetchRequest:request error:&error];
       
    }];
    
    if (error != nil) {
        
        return nil;
    }
    
    return result;
}

- (void)deleteAllObjects {
    
    [self.saveManagedObjectContext reset];
    
    [self deleteAllObjectsForName:@"ITBNews"];
    [self deleteAllObjectsForName:@"ITBCategory"];
    [self deleteAllObjectsForName:@"ITBPhoto"];
}

- (void)deleteAllObjectsForName:(NSString *)entityName {
    
    NSManagedObjectContext *context = self.saveManagedObjectContext;
    
    NSArray *allObjects = [self allObjectsForName:entityName usingContext:context];
    
    for (id object in allObjects) {
        
        [context deleteObject:object];
    }
    
    [self saveCurrentContext:context];
}

- (NSArray *)allObjectsForName:(NSString *)entityName usingContext:(NSManagedObjectContext *)context {
    
    return [self fetchObjectsForName:entityName withSortDescriptor:nil predicate:nil inContext:context];
}

- (void)deleteAllUsers {
    
    [self deleteAllObjectsForName:@"ITBUser"];
}

- (void)addRelationsToLocalDBFromNewsDictsArray:(NSArray *)newsDicts forNewsArray:(NSArray *)newsArray fromCategoryDictsArray:(NSArray *)categoryDicts forCategoriesArray:(NSArray *)categoriesArray fromPhotoDictsArray:(NSArray *)allPhotoDicts forPhotosArray:(NSArray *)allPhotosArray forUser: (ITBUser *)currentUser usingContext:(NSManagedObjectContext *)context onSuccess:(void(^)(BOOL isSuccess))success {
    
    [context performBlockAndWait:^{
        
        for (NSDictionary *newsDict in newsDicts) {
            
            ITBNews *newsItem = [newsArray objectAtIndex:[newsDicts indexOfObject:newsDict]];
            
            NSDictionary *authorDict = [newsDict objectForKey:@"author"];
            NSArray *likeAddedUsersDictsArray = [newsDict objectForKey:@"likeAddedUsers"];
            NSDictionary *categoryOfNewsItemDict = [newsDict objectForKey:@"category"];
            NSArray *photoOfNewsItemDictsArray = [newsDict objectForKey:@"photos"];
            NSArray *thumbnailPhotoOfNewsItemDictsArray = [newsDict objectForKey:@"thumbnailPhotos"];
            
            if ([currentUser.objectId isEqualToString:[authorDict objectForKey:@"objectId"]]) {
                
                newsItem.author = currentUser;
            }
            
            for (NSString *likeAddedUserObjectId in likeAddedUsersDictsArray) {
                
                if ([currentUser.objectId isEqualToString:likeAddedUserObjectId]) {
                    
                    [currentUser addLikedNewsObject:newsItem];
                    newsItem.isLikedByCurrentUser = @1;
                }
            }
            
            // photos
            for (NSDictionary *photoOfNewsItemDict in photoOfNewsItemDictsArray) {
                
                NSString *photoOfNewsIteObjectId = [photoOfNewsItemDict objectForKey:@"objectId"];
                
                for (NSDictionary *photoDict in allPhotoDicts) {
                    
                    NSInteger index = [allPhotoDicts indexOfObject:photoDict];
                    
                    if ([photoOfNewsIteObjectId isEqualToString:[photoDict objectForKey:@"objectId"]]) {
                        
                        ITBPhoto *photo = [allPhotosArray objectAtIndex:index];
                        
                        [newsItem addPhotosObject:photo];
                        
                    }
                }
            }
            
            // thumbnailPhotos
            for (NSDictionary *thumbnailPhotoOfNewsItemDict in thumbnailPhotoOfNewsItemDictsArray) {
                
                NSString *thumbnailPhotoOfNewsIteObjectId = [thumbnailPhotoOfNewsItemDict objectForKey:@"objectId"];
                
                for (NSDictionary *photoDict in allPhotoDicts) {
                    
                    NSInteger index = [allPhotoDicts indexOfObject:photoDict];
                    
                    if ([thumbnailPhotoOfNewsIteObjectId isEqualToString:[photoDict objectForKey:@"objectId"]]) {
                        
                        ITBPhoto *thumbnailPhoto = [allPhotosArray objectAtIndex:index];
                        
                        [newsItem addThumbnailPhotosObject:thumbnailPhoto];
                        
                    }
                }
            }
            
            for (NSDictionary *categoryDict in categoryDicts) {
                
                ITBCategory *category = [categoriesArray objectAtIndex:[categoryDicts indexOfObject:categoryDict]];
                
                NSArray *signedUsersDictsArray = [categoryDict objectForKey:@"signedUsers"]; // for category
                
                if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:@"objectId"]]) {
                    
                    newsItem.category = category;
                }
                
                for (NSString *signedUserObjectId in signedUsersDictsArray) {
                    
                    if ([currentUser.objectId isEqualToString:signedUserObjectId]) {
                        
                        [currentUser addSelectedCategoriesObject:category];
                        
                    }
                }
            }
        }
        
        // first saving to current context
        NSError *error = nil;
        BOOL saved = [context save:&error];
        if (!saved) {
            NSLog(@"Error saving context: %@", error);
        }
        // and finally saving to saveContext
        [self saveSaveContext];
        
        success(YES);
        
    }];
    
    
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
