//
//  ITBCoreDataManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCoreDataManager.h"

#import "ITBUtils.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"
#import "ITBPhoto.h"

static NSString * const modelName = @"NewsSearch";
static NSString * const modelExt = @"momd";
static NSString * const databaseName = @"NewsSearch.sqlite";

@interface ITBCoreDataManager ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *bgManagedObjectContext;

@property (strong, nonatomic) NSManagedObjectContext *saveManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *syncManagedObjectContext;

@end

@implementation ITBCoreDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize bgManagedObjectContext = _bgManagedObjectContext;

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:modelExt];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseName];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)bgManagedObjectContext {
    
    if (_bgManagedObjectContext != nil) {
        return _bgManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        
        _bgManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_bgManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _bgManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveMainContext {
    
    NSError *error = nil;
    BOOL saved = [self.mainManagedObjectContext save:&error];
    
    if (!saved) {
        
        NSLog(@"%@ %@\n%@", contextSavingError, [error localizedDescription], [error userInfo]);
    }
}

- (void)saveBgContext {
    
    NSError *error = nil;
    BOOL saved = [self.bgManagedObjectContext save:&error];
    
    if (!saved) {
        
        NSLog(@"%@ %@\n%@", bgContextSavingError, [error localizedDescription], [error userInfo]);
    }
}

#pragma mark - Public

- (NSArray *)fetchObjectsForName:(NSString *)entityName withSortDescriptor:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    
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
    
    NSError *error = nil;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
        return nil;
    }
    
    return result;
}

- (NSArray *)allObjectsForName:(NSString *)entityName usingContext:(NSManagedObjectContext *)context {
    
    return [self fetchObjectsForName:entityName withSortDescriptor:nil predicate:nil inContext:context];
}

- (void)addRelationsToLocalDBFromNewsDictsArray:(NSArray *)newsDicts forNewsArray:(NSArray *)newsArray fromCategoryDictsArray:(NSArray *)categoryDicts forCategoriesArray:(NSArray *)categoriesArray fromPhotoDictsArray:(NSArray *)allPhotoDicts forPhotosArray:(NSArray *)allPhotosArray forUser:(ITBUser *)currentUser usingContext:(NSManagedObjectContext *)context onSuccess:(void(^)(BOOL isSuccess))success {
    
    for (NSDictionary *newsDict in newsDicts) {
        
        ITBNews *newsItem = [newsArray objectAtIndex:[newsDicts indexOfObject:newsDict]];
        
        NSDictionary *authorDict = [newsDict objectForKey:authorDictKey];
        NSArray *likeAddedUsersDictsArray = [newsDict objectForKey:likeAddedUsersDictKey];
        NSDictionary *categoryOfNewsItemDict = [newsDict objectForKey:categoryDictKey];
        NSArray *photoOfNewsItemDictsArray = [newsDict objectForKey:photosDictKey];
        NSArray *thumbnailPhotoOfNewsItemDictsArray = [newsDict objectForKey:thumbnailPhotosDictKey];
        
        if ([currentUser.objectId isEqualToString:[authorDict objectForKey:objectIdDictKey]]) {
            
            newsItem.author = currentUser;
        }
        
        for (NSString *likeAddedUserObjectId in likeAddedUsersDictsArray) {
            
            if ([currentUser.objectId isEqualToString:likeAddedUserObjectId]) {
                
                [currentUser addLikedNewsObject:newsItem];
                newsItem.isLikedByCurrentUser = @1;
            }
        }
        
        for (NSDictionary *photoOfNewsItemDict in photoOfNewsItemDictsArray) {
            
            NSString *photoOfNewsItemObjectId = [photoOfNewsItemDict objectForKey:objectIdDictKey];
            
            for (NSDictionary *photoDict in allPhotoDicts) {
                
                NSInteger index = [allPhotoDicts indexOfObject:photoDict];
                
                if ([photoOfNewsItemObjectId isEqualToString:[photoDict objectForKey:objectIdDictKey]]) {
                    
                    ITBPhoto *photo = [allPhotosArray objectAtIndex:index];
                    
                    [newsItem addPhotosObject:photo];
                    
                }
            }
        }
        
        for (NSDictionary *thumbnailPhotoOfNewsItemDict in thumbnailPhotoOfNewsItemDictsArray) {
            
            NSString *thumbnailPhotoOfNewsItemObjectId = [thumbnailPhotoOfNewsItemDict objectForKey:objectIdDictKey];
            
            for (NSDictionary *photoDict in allPhotoDicts) {
                
                NSInteger index = [allPhotoDicts indexOfObject:photoDict];
                
                if ([thumbnailPhotoOfNewsItemObjectId isEqualToString:[photoDict objectForKey:objectIdDictKey]]) {
                    
                    ITBPhoto *thumbnailPhoto = [allPhotosArray objectAtIndex:index];
                    
                    [newsItem addThumbnailPhotosObject:thumbnailPhoto];
                    
                }
            }
        }
        
        for (NSDictionary *categoryDict in categoryDicts) {
            
            ITBCategory *category = [categoriesArray objectAtIndex:[categoryDicts indexOfObject:categoryDict]];
            
            NSArray *signedUsersDictsArray = [categoryDict objectForKey:signedUsersDictKey];
            
            if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:objectIdDictKey]]) {
                
                newsItem.category = category;
            }
            
            for (NSString *signedUserObjectId in signedUsersDictsArray) {
                
                if ([currentUser.objectId isEqualToString:signedUserObjectId]) {
                    
                    [currentUser addSelectedCategoriesObject:category];
                    
                }
            }
        }
    }
    
    NSError *error = nil;
    BOOL saved = [context save:&error];
    
    if (!saved) {
        
        NSLog(@"%@ %@\n%@", bgContextSavingError, [error localizedDescription], [error userInfo]);
    }
    
    success(YES);
    
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
