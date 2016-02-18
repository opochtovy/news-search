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

// GET method for class ITBSignInTableViewController for getting all users before writing a new username in the usernameField
- (void)getNewsOnSuccess:(void(^)(NSArray *news)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// PUT method for class ITBNewsViewController after pressing buttons "+" or "-"
- (void)updateRatingFromUserForNewsItem:(ITBNews* ) news
                              onSuccess:(void(^)(NSDate* updatedAt)) success
                              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// PUT method for class ITBCategoriesViewController after choosing categories
- (void)updateCategoriesFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getCategoriesOnSuccess:(void(^)(NSArray *categories)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end
