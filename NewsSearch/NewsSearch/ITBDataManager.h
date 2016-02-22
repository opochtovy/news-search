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

extern NSString *const kSettingsObjectId;

@interface ITBDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) ITBUser *currentUser;
@property (strong, nonatomic) ITBUserCD *currentUserCD;

@property (strong, nonatomic) NSArray* allCategoriesArray;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (ITBDataManager *)sharedManager;

// ЭТИ МЕТОДЫ ДЛЯ СОХРАНЕНИЯ В ЛОКАЛЬНУЮ БД В ТЕСТОВОМ РЕЖИМЕ (РЕЖИМ КОГДА МЫ ВРУЧНУЮ СОЗДАВАЛИ СВЯЗИ ЛОКАЛЬНО А ЗАТЕМ ЗАКАЧИВАЛИ ВСЕ СВЯЗИ НА СЕРВЕР ЧТОБЫ ПОЛУЧИТЬ НА СЕРВЕРЕ ПОЛНОЦЕННУЮ РАБОЧУЮ БД)

// these 3 properties ДЛЯ СОХРАНЕНИЯ В ЛОКАЛЬНУЮ БД В ТЕСТОВОМ РЕЖИМЕ
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSArray *categoriesArray;
@property (strong, nonatomic) NSArray *newsArray;

- (void)addNewsToLocalDBFromLoadedArray:(NSArray* ) news;
- (void)addCategoriesToLocalDBFromLoadedArray:(NSArray* ) categories;
- (void) addCurrentUserToLocalDB;
- (void)addUsersToLocalDBFromLoadedArray:(NSArray* ) users;

- (void) addRelations;
- (void) addRelationsManually;
- (void) addRelationsManually2; // I use that method to create all relations manually

// КОНЕЦ - ЭТИ МЕТОДЫ ДЛЯ СОХРАНЕНИЯ В ЛОКАЛЬНУЮ БД В ТЕСТОВОМ РЕЖИМЕ (РЕЖИМ КОГДА МЫ ВРУЧНУЮ СОЗДАВАЛИ СВЯЗИ ЛОКАЛЬНО А ЗАТЕМ ЗАКАЧИВАЛИ ВСЕ СВЯЗИ НА СЕРВЕР ЧТОБЫ ПОЛУЧИТЬ НА СЕРВЕРЕ ПОЛНОЦЕННУЮ РАБОЧУЮ БД)

// ЭТИ МЕТОДЫ УЖЕ ДЛЯ refresh КОГДА МЫ С ПОЛНОЦЕННОЙ БД НА СЕРВЕРЕ ЗАКАЧИВАЕМ В ЛОКАЛЬНУЮ БД АТРИБУТЫ И СВЯЗИ
- (void)addNewsToLocalDBForNewsDictsArray:(NSArray* ) news;
- (void)addCategoriesToLocalDBForCategoriesDictsArray:(NSArray* ) categories;
- (void)addUsersToLocalDBForUsersDictsArray:(NSArray* ) users;

- (void)addAllObjectsToLocalDBForDict:(NSDictionary* ) dict
                            onSuccess:(void(^)(BOOL isSuccess)) success;

// КОНЕЦ - ЭТИ МЕТОДЫ УЖЕ ДЛЯ refresh КОГДА МЫ С ПОЛНОЦЕННОЙ БД НА СЕРВЕРЕ ЗАКАЧИВАЕМ В ЛОКАЛЬНУЮ БД АТРИБУТЫ И СВЯЗИ

- (void)printAllObjects;

- (void)fetchCurrentUserForObjectId:(NSString* ) objectId;
- (void)fetchAllCategories;

// methods for NSUserDefaults
- (void)saveSettings;
- (void)loadSettings;

@end
