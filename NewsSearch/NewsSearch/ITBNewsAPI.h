//
//  ITBNewsAPI.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class ITBNews;
@class ITBCategory;
@class ITBUser;

extern NSString *const login;
extern NSString *const logout;
extern NSString *const beforeLogin;


@interface ITBNewsAPI : NSObject

@property (strong, nonatomic) ITBUser* currentUser;

+ (ITBNewsAPI *)sharedInstance;

// NSUserDefaults
- (void)saveCurrentUser;
- (void)loadCurrentUser;

- (void) logOut;

// ITBRestClient

- (void)authorizeWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(ITBUser* user)) success;

- (void)registerWithUsername:(NSString* ) username
                withPassword:(NSString* ) password
                   onSuccess:(void(^)(BOOL isSuccess)) success;

- (void)getUsersOnSuccess:(void(^)(NSSet *usernames)) success;

- (void) checkNetworkConnectionOnSuccess:(void(^)(BOOL isSuccess)) success;

// ITBCoreDataManager

@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

- (void)saveMainContext;

- (NSArray* )fetchAllCategories;
- (NSArray* )fetchAllObjectsForEntity:(NSString* ) entityName;

- (NSArray* )newsInLocalDB;

- (void) createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success;
- (void) updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success;

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess)) success;

@end
