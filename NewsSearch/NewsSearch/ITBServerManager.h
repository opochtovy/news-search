//
//  ITBServerManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// класс singleton для общения с сервером

#import <Foundation/Foundation.h>

@class ITBUser;
@class ITBNews;

@class ITBNewsCD;
@class ITBCategoryCD;
@class ITBUserCD;

@interface ITBServerManager : NSObject

+ (ITBServerManager *)sharedManager;

// GET method for class ITBLoginTableViewController after pressing button "Login"
- (void)authorizeWithUsername:(NSString* ) username
         withPassword:(NSString* ) password
            onSuccess:(void(^)(ITBUser* user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// POST method for class ITBSignInTableViewController after pressing button "Sign in"
- (void)registerWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(ITBUser* user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// GET method for class ITBSignInTableViewController for getting all users before writing a new username in the usernameField
- (void)getUsersOnSuccess:(void(^)(NSArray *users)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// GET method for class ITBDataManager and ITBNewsViewController for getting all news from server (client-server version of app)
- (void)getNewsOnSuccess:(void(^)(NSArray *news)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// PUT method for class ITBNewsViewController after pressing buttons "+" or "-"
- (void)updateRatingFromUserForNewsItem:(ITBNews* ) news
                              onSuccess:(void(^)(NSDate* updatedAt)) success
                              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// PUT method for class ITBCategoriesViewController after choosing categories
- (void)updateCategoriesFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// GET method for class ITBHotNewsViewController in -actionRefresh: - method to get just attributes for users from server for saving them to local DB (without relations)
- (void)getAllUsersOnSuccess:(void(^)(NSArray *users)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// GET method for class ITBHotNewsViewController in -actionRefresh: - method to get just attributes for categories from server for saving them to local DB (without relations)
- (void)getCategoriesOnSuccess:(void(^)(NSArray *categories)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// GET method for class ITBHotNewsViewController in -actionRefresh: - method to get just attributes for news from server for saving them to local DB (without relations)
- (void)getAllNewsOnSuccess:(void(^)(NSArray *news)) success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// === МЕТОДЫ ОБНОВЛЯЮЩИЕ СВЯЗИ of currentUserCD НА СЕРВЕР

// methods for uploading current user changes to server before refreshing all data from server to local DB
- (void)uploadToServerUserRelationsForUser:(ITBUserCD* ) user
                         onSuccess:(void(^)(NSDate* updatedAt)) success
                         onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)uploadToServerCategoryRelationsForCategory:(ITBCategoryCD* ) category
                             onSuccess:(void(^)(NSDate* updatedAt)) success
                             onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)uploadToServerNewsRelationsForNewsItem:(ITBNewsCD* ) newsItem
                             onSuccess:(void(^)(NSDate* updatedAt)) success
                                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// method for refreshButton
- (void) updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success;

// === КОНЕЦ - МЕТОДЫ ОБНОВЛЯЮЩИЕ СВЯЗИ of currentUserCD НА СЕРВЕР

// === ТЕСТОВЫЕ МЕТОДЫ

- (void) createLocalDataSource;

// тестовый метод для createLocalDataSource в ITBHotNewsViewController.m - загружаю с локальной БД на сервер все связи для ITBNewsCD (тестовый режим)
- (void)updateAllRelationsForNewsItem:(ITBNewsCD* ) news
                            onSuccess:(void(^)(NSDate* updatedAt)) success
                            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// тестовый метод для createLocalDataSource в ITBHotNewsViewController.m - загружаю с локальной БД на сервер все связи для ITBCategoryCD (тестовый режим)
- (void)updateAllRelationsForCategory:(ITBCategoryCD* ) category
                            onSuccess:(void(^)(NSDate* updatedAt)) success
                            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// тестовый метод для createLocalDataSource в ITBHotNewsViewController.m - загружаю с локальной БД на сервер все связи для ITBUserCD (тестовый режим)
- (void)updateAllRelationsForUser:(ITBUserCD* ) user
                        onSuccess:(void(^)(NSDate* updatedAt)) success
                        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// === КОНЕЦ - ТЕСТОВЫЕ МЕТОДЫ

@end
