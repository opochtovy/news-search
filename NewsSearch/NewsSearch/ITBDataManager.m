//
//  ITBDataManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBDataManager.h"

#import "ITBUser.h"
#import "ITBNews.h"

#import "ITBServerManager.h"

#import "ITBNewsCD.h"
#import "ITBCategoryCD.h"
#import "ITBUserCD.h"

@interface ITBDataManager ()

@end

@implementation ITBDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (ITBDataManager *)sharedManager {
    
    static ITBDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[ITBDataManager alloc] init];
        
    });
    
    return manager;
}

# pragma mark - Private Methods

// выборка всех объектов
- (NSArray *)allObjects {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBObject"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}

- (void)deleteAllObjects {
    
    NSArray *allObjects = [self allObjects];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
}

- (void)printArray:(NSArray *)array {
    
    for (id object in array) {
        
        if ([object isKindOfClass:[ITBNewsCD class]]) {
            
            ITBNewsCD *newsItem = (ITBNewsCD *)object;
            NSLog(@"NEWS title : %@ and URL %@, created at : %@, updated at : %@ AND category = %@ AND author = %@ AND number of likeAddedUsers = %ld AND newsItem.rating = %@", newsItem.title, newsItem.newsURL, newsItem.createdAt, newsItem.updatedAt, newsItem.category.title, newsItem.author.username, [newsItem.likeAddedUsers count], newsItem.rating);
            
        } else if ([object isKindOfClass:[ITBCategoryCD class]]) {
            
            ITBCategoryCD *category = (ITBCategoryCD *)object;
            NSLog(@"CATEGORY title : %@ and objectId = %@ and number of news in that category = %ld and number of signed users = %ld", category.title, category.objectId, [category.news count], [category.signedUsers count]);
            
        } else if ([object isKindOfClass:[ITBUserCD class]]) {
            
            ITBUserCD *user = (ITBUserCD *)object;
            NSLog(@"USER username : %@ and objectId = %@ and number of created news = %ld and number of liked news = %ld and number of selected categories = %ld", user.username, user.objectId, [user.createdNews count], [user.likedNews count], [user.selectedCategories count]);
            
        }
        
    }
    
}

- (void) printAllObjects {

    NSArray *allObjects = [self allObjects];
    [self printArray:allObjects];

}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

- (void)fetchCurrentUserForObjectId:(NSString* ) objectId {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBUserCD"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *currentUserArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    self.currentUserCD = [currentUserArray firstObject];
    
}

# pragma mark - API

- (void)addNewsToLocalDBFromLoadedArray:(NSArray* ) news {
    
    // эта строка удаляет все объекты из permanent store
    [self deleteAllObjects];
    
    for (NSDictionary* newsDict in news) {
        
        ITBNewsCD *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNewsCD" inManagedObjectContext:self.managedObjectContext];
        
        newsItem.objectId = [newsDict objectForKey:@"objectId"];
        newsItem.title = [newsDict objectForKey:@"title"];
        newsItem.newsURL = [newsDict objectForKey:@"newsURL"];
        
        // createdAt and updatedAt are UTC timestamps stored in ISO 8601 format with millisecond precision: YYYY-MM-DDTHH:MM:SS.MMMZ.
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"updatedAt"]];
    }
    
    NSError *error = nil;
    
    // здесь идет сохранение в permanent store
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    // а здесь первый пример of NSFetchRequest
    
    [self printAllObjects];
    
    [self allObjects];
    
}


- (void)addCategoriesToLocalDBFromLoadedArray:(NSArray* ) categories {
    
    for (NSDictionary* catDict in categories) {
        
        ITBCategoryCD *category = [NSEntityDescription insertNewObjectForEntityForName:@"ITBCategoryCD" inManagedObjectContext:self.managedObjectContext];
        
        category.objectId = [catDict objectForKey:@"objectId"];
        category.title = [catDict objectForKey:@"title"];
    }
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self printAllObjects];
    
    [self allObjects];
}

- (void) addCurrentUserToLocalDB {
    
    ITBServerManager* serverManager = [ITBServerManager sharedManager];
    
    ITBUserCD* user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUserCD" inManagedObjectContext:self.managedObjectContext];
    
    NSLog(@"serverManager.currentUser.objectId = %@", serverManager.currentUser.objectId);
    NSLog(@"serverManager.currentUser.username = %@", serverManager.currentUser.username);
    
    user.objectId = serverManager.currentUser.objectId;
    user.username = serverManager.currentUser.username;
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self printAllObjects];
    
    [self allObjects];
}

- (void) addRelationsManually {
    
    // code for setting all my relations manually

     // 1st fetchRequest for News
     NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
     
     NSEntityDescription *description1 = [NSEntityDescription
     entityForName:@"ITBNewsCD"
     inManagedObjectContext:self.managedObjectContext];
     
     [request1 setEntity:description1];
     
     NSError *requestError = nil;
     
     NSArray *resultNewsArray = [self.managedObjectContext executeFetchRequest:request1 error:&requestError];
     
     if (requestError) {
     NSLog(@"%@", [requestError localizedDescription]);
     }
     
     // 2nd fetchRequest for Categories
     NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
     
     NSEntityDescription *description2 = [NSEntityDescription
     entityForName:@"ITBCategoryCD"
     inManagedObjectContext:self.managedObjectContext];
     
     [request2 setEntity:description2];
     
     NSArray *resultCategoriesArray = [self.managedObjectContext executeFetchRequest:request2 error:&requestError];
     
     if (requestError) {
     NSLog(@"%@", [requestError localizedDescription]);
     }
     
     // 3rd fetchRequest for currentUser
     NSFetchRequest *request3 = [[NSFetchRequest alloc] init];
     
     NSEntityDescription *description3 = [NSEntityDescription
     entityForName:@"ITBUserCD"
     inManagedObjectContext:self.managedObjectContext];
     
     [request3 setEntity:description3];
     
     NSArray *resultUserArray = [self.managedObjectContext executeFetchRequest:request3 error:&requestError];
     
     if (requestError) {
     NSLog(@"%@", [requestError localizedDescription]);
     }
     
     ITBUserCD* currentUser = [resultUserArray firstObject];
     
     for (ITBNewsCD* newsItem in resultNewsArray) {
     
         newsItem.author = currentUser;
     
         [newsItem addLikeAddedUsersObject:currentUser];
         
/*
     NSInteger ratingInt = [newsItem.rating integerValue];
     newsItem.rating = [NSNumber numberWithInteger:++ratingInt];
*/
     for (ITBCategoryCD* category in resultCategoriesArray) {
     
     [category addSignedUsersObject:currentUser];
     
     if ( ([newsItem.objectId isEqualToString:@"JlnHtVqzlP"]) && ([category.title isEqualToString:@"sport"]) ) {
     
     newsItem.category = category;
     
     } else if ( ([newsItem.objectId isEqualToString:@"etpe6DlNgc"]) && ([category.title isEqualToString:@"realty"]) ) {
     
     newsItem.category = category;
     
     } else if ( ([newsItem.objectId isEqualToString:@"vuyVshsCZt"]) && ([category.title isEqualToString:@"weather"]) ) {
     
     newsItem.category = category;
     
     }
     
     }
     
     }
     
     NSError *error = nil;
     
     // здесь идет сохранение в permanent store
     if (![self.managedObjectContext save:&error]) {
     
     NSLog(@"%@", [error localizedDescription]);
     }

    // end of code for setting all my relations manually
    
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
        
        /*
         // Report any error we got.
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
         dict[NSLocalizedFailureReasonErrorKey] = failureReason;
         dict[NSUnderlyingErrorKey] = error;
         error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
         // Replace this with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         */
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
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

@end
