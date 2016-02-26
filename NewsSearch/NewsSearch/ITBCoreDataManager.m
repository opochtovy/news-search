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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
        
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

- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator == nil) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            /*
             UIAlertController* alert = [UIAlertController
             alertControllerWithTitle:@"Error"
             message:[error localizedDescription]
             preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction* defaultAction = [UIAlertAction
             actionWithTitle:@"OK"
             style:UIAlertActionStyleDefault
             
             handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
             */
        }
    }
}


- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBUser"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *currentUserArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError != nil) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return [currentUserArray firstObject];
    
}

- (NSArray* )fetchAllCategories {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBCategory"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError != nil) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}

- (NSArray *)allObjectsForName:(NSString* ) entityName {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:entityName
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    NSLog(@"count of %@ objects - %li", entityName, (long)[resultArray count]);
    
    return resultArray;
    
}

- (void)deleteAllObjectsForName:(NSString* ) entityName {
    
    NSArray *allObjects = [self allObjectsForName:entityName];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    // здесь идет сохранение в permanent store
    [self.managedObjectContext save:nil];
}

- (void)deleteAllObjects
{
    [self deleteAllObjectsForName:@"ITBNews"];
    [self deleteAllObjectsForName:@"ITBCategory"];
    [self deleteAllObjectsForName:@"ITBUser"];
    
    [self.managedObjectContext save:nil];
}

- (void)deleteObjectsInArray:(NSArray* ) array
{
    for (id object in array) {
        [self.managedObjectContext deleteObject:object];
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
    // эта строка удаляет все объекты из permanent store
//    [self deleteAllObjectsForName:@"ITBNews"];
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in dicts) {
/*
        ITBNews *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNews" inManagedObjectContext:self.managedObjectContext];
        
        newsItem.objectId = [newsDict objectForKey:@"objectId"];
        newsItem.title = [newsDict objectForKey:@"title"];
        newsItem.newsURL = [newsDict objectForKey:@"newsURL"];
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"updatedAt"]];
 */
        ITBNews* newsItem = [[ITBNews alloc] insertObjectWithDictionary:newsDict inContext:self.managedObjectContext];
        
        [newsArray addObject:newsItem];
    }
    
//    NSLog(@"1st method");
//    [self printAllObjectsForName:@"ITBNews"];
    
/*
    // здесь идет сохранение в permanent store
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
     
         NSLog(@"%@", [error localizedDescription]);
     }
*/
    
    return [newsArray copy];
}

- (NSArray* )updateNewsToLocalDBFromLoadedArray:(NSArray* ) dicts
                                forLocalObjects:(NSArray* ) updatedNewsArray
{
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in dicts) {
        
        ITBNews* newsItem = [updatedNewsArray objectAtIndex:[dicts indexOfObject:newsDict]];
        
        [newsItem updateObjectWithDictionary:newsDict inContext:self.managedObjectContext];
        
        [newsArray addObject:newsItem];
    }
    
    return [newsArray copy];
}

- (NSArray* )addCategoriesToLocalDBFromLoadedArray:(NSArray* ) dicts
{
    
    // эта строка удаляет все объекты из permanent store
//    [self deleteAllObjectsForName:@"ITBCategory"];
    
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* catDict in dicts) {
        
        ITBCategory* category = [[ITBCategory alloc] insertObjectWithDictionary:catDict inContext:self.managedObjectContext];
        
        [categoriesArray addObject:category];
    }
    
//    NSLog(@"2nd method");
//    [self printAllObjectsForName:@"ITBCategory"];
    
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
//            NSLog(@"Relation for news (author) %@ - %@", newsItem.title, currentUser.username);
        }
        
        for (NSDictionary* likeAddedUserDict in likeAddedUsersDictsArray) {
            
            if ([currentUser.objectId isEqualToString:[likeAddedUserDict objectForKey:@"objectId"]]) {
                
                [currentUser addLikedNewsObject:newsItem];
//                NSLog(@"Relation for news (likeAddedUser) %@ - %@", newsItem.title, currentUser.username);
            }
        }
    
        
        for (NSDictionary* categoryDict in categoryDicts) {
            
            ITBCategory* category = [categoriesArray objectAtIndex:[categoryDicts indexOfObject:categoryDict]];
            
            NSArray* signedUsersDictsArray = [categoryDict objectForKey:@"signedUsers"]; // for category
            
            if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:@"objectId"]]) {
                
                newsItem.category = category;
//                NSLog(@"Relation for news (category) %@ - %@", newsItem.title, category.title);
                
            }
            
            for (NSDictionary* signedUserDict in signedUsersDictsArray) {
                
                if ([currentUser.objectId isEqualToString:[signedUserDict objectForKey:@"objectId"]]) {
                    
                    [currentUser addSelectedCategoriesObject:category];
//                    NSLog(@"Relation for user (selectedCategory) %@ - %@", currentUser.username, category.title);
                    
                }
            }
        }
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"error localizedDescription = %@", [error localizedDescription]);
    }
    
    [self printAllObjects];
    
    success(YES);
}

@end
