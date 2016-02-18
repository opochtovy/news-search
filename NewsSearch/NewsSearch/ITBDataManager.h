//
//  ITBDataManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ITBUser;
@class ITBUserCD;

extern NSString *const login;
extern NSString *const logout;
extern NSString *const beforeLogin;

@interface ITBDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) ITBUser *currentUser;
@property (strong, nonatomic) ITBUserCD *currentUserCD;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (ITBDataManager *)sharedManager;

- (void)addNewsToLocalDBFromLoadedArray:(NSArray* ) news;
- (void)addCategoriesToLocalDBFromLoadedArray:(NSArray* ) categories;
- (void) addCurrentUserToLocalDB;
- (void) addRelationsManually;

- (void)printAllObjects;

- (void)fetchCurrentUserForObjectId:(NSString* ) objectId;
- (NSArray* )fetchAllCategories;

// methods for NSUserDefaults
- (void)saveSettings;
- (void)loadSettings;

@end
